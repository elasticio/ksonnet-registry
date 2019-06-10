local k = import 'k.libsonnet';
{
  app(
    version,
    port = 3002,
    redisConfig = {
      name: 'maester',
      sentinels: [{
        host: 'maester-redis-ha',
        port: 26379
      }]
    },
    maesterReplicas = 3,
    terminationGracePeriodSeconds = 30,
    appName = 'maester',
  ):: [
      {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
              labels: {
                  app: appName
              },
              name: appName + '-service',
              namespace: 'platform'
          },
          spec: {
              ports: [
                  {
                      name: 'http',
                      port: port,
                      protocol: 'TCP',
                      targetPort: port
                  }
              ],
              selector: {
                  app: appName
              },
              sessionAffinity: 'None',
              type: 'ClusterIP'
          }
      },
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: appName,
          namespace: 'platform',
          labels: {
            app: appName,
          },
        },
        spec: {
          replicas: maesterReplicas,
          selector: {
            matchLabels: {
              app: appName,
            },
          },
          template: {
            metadata: {
              name: appName,
              labels: {
                app:appName,
              },
            },
            spec: {
              affinity: {
                nodeAffinity: {
                  requiredDuringSchedulingIgnoredDuringExecution: {
                    nodeSelectorTerms: [
                      {
                        matchExpressions: [
                          {
                            key: 'elasticio-role',
                            operator: 'In',
                            values: [
                              'platform'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                },
                podAntiAffinity: {
                  requiredDuringSchedulingIgnoredDuringExecution: [
                    {
                      labelSelector: {
                        matchLabels: {
                          app: appName
                        }
                      },
                      topologyKey: 'kubernetes.io/hostname'
                    }
                  ]
                }
              },
              securityContext: {
                  fsGroup: 1000,
                  runAsNonRoot: true,
                  runAsUser: 1000
              },
              containers: [
                {
                  name: appName,
                  image: 'elasticio/maester:' + version,
                  envFrom: [
                    {
                      secretRef: {
                        name: 'elasticio',
                      },
                    },
                  ],
                  env: [
                    {
                        name: 'APP_NAME',
                        value: appName
                    },
                    {
                        name: 'LOG_LEVEL',
                        value: 'info'
                    },
                    {
                        name: 'REDIS_CONFIG',
                        value: std.manifestJsonEx(redisConfig, ' ')
                    },
                    {
                        name: 'TERMINATION_DELAY',
                        value: std.toString(terminationGracePeriodSeconds / 2)
                    },
                    {
                        name: 'JWT_SECRET',
                        valueFrom: {
                          secretKeyRef: {
                            name: 'elasticio',
                            key: 'MAESTER_JWT_SECRET',
                          },
                        },
                    },
                    {
                      name: 'PORT',
                      value: std.toString(port)
                    },
                  ],
                  livenessProbe: {
                      httpGet: {
                          path: '/healthcheck',
                          port: port,
                          scheme: 'HTTP'
                      }
                  },
                  readinessProbe: {
                    httpGet: {
                        path: '/healthcheck',
                        port: port,
                        scheme: 'HTTP'
                    }
                  },
                  ports: [
                    {
                      containerPort: port,
                      protocol: 'TCP',
                    },
                  ],
                  resources: {
                    limits: {
                      memory: '2048Mi',
                      cpu: 1,
                    },
                    requests: {
                      memory: '512Mi',
                      cpu: 0.1,
                    },
                  },
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File',
                  imagePullPolicy: 'IfNotPresent'
                },
              ],
              imagePullSecrets: [
                {
                  name: 'elasticiodevops',
                },
              ],
              restartPolicy: 'Always',
              terminationGracePeriodSeconds: terminationGracePeriodSeconds,
              nodeSelector: {
                'elasticio-role': 'platform',
              },
            },
          },
          strategy: {
            type: 'RollingUpdate',
            rollingUpdate: {
              maxUnavailable: 1,
              maxSurge: 1,
            },
          },
        },
      }
    ],
  redis(
      redisClusterName = 'maester-cluster',
      redisAppName = 'maester-redis-ha',
      redisReplicas = 3,
      maxMemGB = 1,
      storageSize = '1Ti',
      redisDataDir = '/data',
      redisConfigDir = '/readonly-config',
      redisConfigMapName = redisAppName + '-configmap',
    )::
    if redisReplicas < 3 then error 'Redis replicas must be 3 or more' else [] +
    [
      k.core.v1.configMap.new(
        redisConfigMapName,
        {
          'redis.conf': |||
            dir "%(dataDir)s"
            appendonly yes
            maxmemory %(maxMem)dgb
            maxmemory-policy volatile-lru
            min-slaves-max-lag 5
            min-slaves-to-write 1
            rdbchecksum yes
            rdbcompression yes
            repl-diskless-sync no
            save 900 1
            client-output-buffer-limit slave 536870912 536870912 0
          ||| % { clusterName: redisClusterName, dataDir: redisDataDir, configDir: redisConfigDir, maxMem: maxMemGB },
          'sentinel.conf': |||
            dir "%(dataDir)s"
            sentinel down-after-milliseconds  %(redisClusterName)s 10000
            sentinel failover-timeout  %(redisClusterName)s 180000
            sentinel parallel-syncs  %(redisClusterName)s 5
          ||| % { redisClusterName: redisClusterName, dataDir: redisDataDir, configDir: redisConfigDir },
          'init.sh': |||
            MASTER=`redis-cli -h %(redisAppName)s -p 26379 sentinel get-master-addr-by-name %(redisClusterName)s | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
            REDIS_CONF=%(dataDir)s/conf/redis.conf
            SENTINEL_CONF=%(dataDir)s/conf/sentinel.conf

            set -e
            function sentinel_update(){
                echo "Updating sentinel config"
                sed -i "1s/^/sentinel monitor %(redisClusterName)s $1 6379 2 \n/" $SENTINEL_CONF
            }

            function redis_update(){
                echo "Updating redis config"
                echo "slaveof $1 6379" >> $REDIS_CONF
            }

            function setup_defaults(){
                echo "Setting up defaults"
                if [[ "$HOSTNAME" == "%(redisAppName)s-0" ]]; then
                    echo "Setting this pod as the default master"
                    sed -i "s/^.*slaveof.*//" $REDIS_CONF
                    sentinel_update "$POD_IP"
                else
                    echo "Setting default slave config.."
                    echo "slaveof %(redisAppName)s-0.%(redisAppName)s 6379" >> $REDIS_CONF
                    sentinel_update "%(redisAppName)s-0.%(redisAppName)s"
                    redis_update "%(redisAppName)s-0.%(redisAppName)s"
                fi
            }

            function find_master(){
                echo "Attempting to find master"
                if [[ ! `redis-cli -h $MASTER ping` ]]; then
                  echo "Can't ping master, attempting to force failover"
                  if redis-cli -h %(redisAppName)s -p 26379 sentinel failover %(redisClusterName)s | grep -q 'NOGOODSLAVE' ; then
                      setup_defaults
                      return 0
                  fi
                  sleep 10
                  MASTER=`redis-cli -h %(redisAppName)s -p 26379 sentinel get-master-addr-by-name %(redisClusterName)s | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
                  if [[ "$MASTER" ]]; then
                      sentinel_update $MASTER
                      redis_update $MASTER
                  else
                      echo "Could not failover, exiting..."
                      exit 1
                  fi
                else
                    echo "Found reachable master, updating config"
                    sentinel_update $MASTER
                    redis_update $MASTER
                fi
            }

            mkdir -p %(dataDir)s/conf/
            echo "Initializing config.."

            cp  %(configDir)s/redis.conf $REDIS_CONF
            cp  %(configDir)s/sentinel.conf $SENTINEL_CONF

            if [[ "$MASTER" ]]; then
                find_master
            else
                setup_defaults
            fi
            if [[ "$AUTH" ]]; then
                echo "Setting auth values"
                sed -i "s/replace-default-auth/$AUTH/" $REDIS_CONF $SENTINEL_CONF
            fi

            echo "Ready..."
          ||| % { redisAppName: redisAppName, redisClusterName: redisClusterName, dataDir: redisDataDir, configDir: redisConfigDir },
        },
      ).withNamespace('platform').withLabels({ app: redisAppName }),
      {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
              labels: {
                  app: redisAppName
              },
              name: redisAppName,
              namespace: 'platform'
          },
          spec: {
              ports: [
                {
                  name: 'server',
                  port: 6379,
                  protocol: 'TCP',
                  targetPort: 'redis'
                },
                {
                  name: 'sentinel',
                  port: 26379,
                  protocol: 'TCP',
                  targetPort: 'sentinel'
                },
              ],
              selector: {
                  app: redisAppName
              },
              sessionAffinity: 'None',
              type: 'ClusterIP'
          }
      },
      {
        apiVersion: 'apps/v1',
        kind: 'StatefulSet',
        metadata: {
          labels: {
            'ksonnet.io/component': 'platform'
          },
          name: redisAppName,
          namespace: 'platform'
        },
        spec: {
          podManagementPolicy: 'OrderedReady',
          replicas: 3,
          selector: {
            matchLabels: {
              app: redisAppName,
            },
          },
          serviceName: redisAppName,
          template: {
            metadata: {
              labels: {
                app: redisAppName
              }
            },
            spec: {
              affinity: {
                nodeAffinity: {
                  requiredDuringSchedulingIgnoredDuringExecution: {
                    nodeSelectorTerms: [
                      {
                        matchExpressions: [
                          {
                            key: 'elasticio-role',
                            operator: 'In',
                            values: [
                              'platform',
                              'maester-redis'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                },
                podAntiAffinity: {
                  preferredDuringSchedulingIgnoredDuringExecution: [
                    {
                      podAffinityTerm: {
                        labelSelector: {
                          matchLabels: {
                            app: redisAppName
                          }
                        },
                        topologyKey: 'failure-domain.beta.kubernetes.io/zone'
                      },
                      weight: 100
                    }
                  ],
                  requiredDuringSchedulingIgnoredDuringExecution: [
                    {
                      labelSelector: {
                        matchLabels: {
                          app: redisAppName
                        }
                      },
                      topologyKey: 'kubernetes.io/hostname'
                    }
                  ]
                }
              },
              containers: [
                {
                  args: [
                    redisDataDir + '/conf/redis.conf'
                  ],
                  command: [
                    'redis-server'
                  ],
                  image: 'redis:5.0.5-alpine',
                  imagePullPolicy: 'IfNotPresent',
                  livenessProbe: {
                    exec: {
                      command: [
                        'redis-cli',
                        'ping'
                      ]
                    },
                    initialDelaySeconds: 15,
                    periodSeconds: 5
                  },
                  name: 'redis',
                  ports: [
                    {
                      containerPort: 6379,
                      name: 'redis'
                    }
                  ],
                  readinessProbe: {
                    exec: {
                      command: [
                        'redis-cli',
                        'ping'
                      ]
                    },
                    initialDelaySeconds: 15,
                    periodSeconds: 5
                  },
                  resources: {
                    limits: {
                      cpu: 1,
                      memory: '%.2gGi' % (maxMemGB + 0.5)
                    },
                    requests: {
                      cpu: 0.1,
                      memory: '512Mi'
                    }
                  },
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File',
                  volumeMounts: [
                    {
                      mountPath: redisDataDir,
                      name: 'data'
                    }
                  ]
                },
                {
                  args: [
                     redisDataDir + '/conf/sentinel.conf'
                  ],
                  command: [
                    'redis-sentinel'
                  ],
                  image: 'redis:5.0.5-alpine',
                  imagePullPolicy: 'IfNotPresent',
                  livenessProbe: {
                    exec: {
                      command: [
                        'redis-cli',
                        '-p',
                        '26379',
                        'ping'
                      ]
                    },
                    initialDelaySeconds: 15,
                    periodSeconds: 5
                  },
                  name: 'sentinel',
                  ports: [
                    {
                      containerPort: 26379,
                      name: 'sentinel'
                    }
                  ],
                  readinessProbe: {
                    exec: {
                      command: [
                        'redis-cli',
                        '-p',
                        '26379',
                        'ping'
                      ]
                    },
                    initialDelaySeconds: 15,
                    periodSeconds: 5
                  },
                  resources: {
                    limits: {
                      cpu: 1,
                      memory: '512Mi'
                    },
                    requests: {
                      cpu: 0.1,
                      memory: '16Mi'
                    }
                  },
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File',
                  volumeMounts: [
                    {
                      mountPath:  redisDataDir,
                      name: 'data'
                    }
                  ]
                }
              ],
              initContainers: [
                {
                  args: [
                     redisConfigDir + '/init.sh'
                  ],
                  command: [
                    'sh'
                  ],
                  env: [
                    {
                      name: 'POD_IP',
                      valueFrom: {
                        fieldRef: {
                          fieldPath: 'status.podIP'
                        }
                      }
                    }
                  ],
                  image: 'redis:5.0.5-alpine',
                  imagePullPolicy: 'IfNotPresent',
                  name: 'config-init',
                  volumeMounts: [
                    {
                      mountPath: redisConfigDir,
                      name: 'config',
                      readOnly: true
                    },
                    {
                      mountPath: redisDataDir,
                      name: 'data'
                    }
                  ]
                }
              ],
              securityContext: {
                fsGroup: 1000,
                runAsNonRoot: true,
                runAsUser: 1000
              },
              volumes: [
                {
                  configMap: {
                    name: redisConfigMapName
                  },
                  name: 'config'
                }
              ]
            }
          },
          updateStrategy: {
            type: 'RollingUpdate'
          },
          volumeClaimTemplates: [
            {
              metadata: {
                labels: {
                  app: redisAppName
                },
                name: 'data'
              },
              spec: {
                accessModes: [
                  'ReadWriteOnce'
                ],
                resources: {
                  requests: {
                    storage: storageSize
                  }
                },
                storageClassName: redisAppName
              }
            }
          ]
        }
      },
        k.storage.v1beta1.storageClass.new()
        + k.storage.v1beta1.storageClass.withProvisioner('kubernetes.io/gce-pd')
        + k.storage.v1beta1.storageClass.withParameters({ type: 'pd-ssd' })
        + k.storage.v1beta1.storageClass.withReclaimPolicy('Retain')
        + k.storage.v1beta1.storageClass.mixin.metadata.withName(redisAppName)
        + k.storage.v1beta1.storageClass.mixin.metadata.withNamespace('platform')
    ],
}
