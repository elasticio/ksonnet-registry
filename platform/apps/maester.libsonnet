local k = import 'k.libsonnet';

{
  app(
    version,
    maesterReplicas,
    terminationGracePeriodSeconds = 30,
    port = 3002,
    redisPort = 6379,
    appName = 'maester',
    redisAppName = appName + '-redis',
    redisConfigMapName = redisAppName + '-configmap',
    redisMaxMemGB = 1,
    redisDataDir = '/data',
  ):: [
      {
          apiVersion: 'v1',
          kind: 'Service',
          metadata: {
              labels: {
                  app: redisAppName
              },
              name: redisAppName + '-service',
              namespace: 'platform'
          },
          spec: {
              ports: [
                  {
                      name: 'http',
                      port: redisPort,
                      protocol: 'TCP',
                      targetPort: redisPort
                  }
              ],
              selector: {
                  app: redisAppName
              }
          }
      },
      {
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: redisConfigMapName,
          namespace: 'platform',
          labels: {
            app: redisAppName,
          },
        },
        data: {
          "redis.conf": |||
              maxmemory %(maxMem)dgb
              maxmemory-policy allkeys-lru
          ||| % { maxMem: redisMaxMemGB }
        },
      },
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: redisAppName,
          namespace: 'platform',
          labels: {
            app: redisAppName,
          },
        },
        spec: {
          replicas: 1,
          selector: {
            matchLabels: {
              app: redisAppName,
            },
          },
          template: {
            metadata: {
              name: redisAppName,
              labels: {
                app: redisAppName,
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
                              'platform'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                }
              },
              containers: [
                {
                  name: 'redis',
                  image: 'redis:5.0.7-alpine',
                  args: [
                    '/readonly-config/redis.conf'
                  ],
                  ports: [{
                    containerPort: 6379
                  }],
                  resources: {
                    limits: {
                      cpu: 1,
                      memory: '%.2gGi' % (redisMaxMemGB + 0.5)
                    },
                    requests: {
                      cpu: 0.1,
                      memory: '512Mi'
                    }
                  },
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
                  imagePullPolicy: 'IfNotPresent',
                  volumeMounts: [
                    {
                      mountPath: '/readonly-config',
                      name: 'config',
                      readOnly: true
                    }
                  ],
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File'
                }
              ],
              imagePullSecrets: [
                {
                  name: 'elasticiodevops',
                },
              ],
              restartPolicy: 'Always',
              terminationGracePeriodSeconds: terminationGracePeriodSeconds,
              volumes: [
                {
                  configMap: {
                    name: redisConfigMapName
                  },
                  name: 'config'
                }
              ]
            },
          }
        },
      },
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
              }
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
                app: appName,
              },
              annotations: {
                "prometheus.io/scrape": "true",
                "prometheus.io/port": std.toString(port)
              },
            },
            spec: {
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
                        name: 'REDIS_URI',
                        valueFrom: {
                          secretKeyRef: {
                            name: 'elasticio',
                            key: 'MAESTER_REDIS_URI',
                          },
                        },
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
                      name: 'OBJECTS_TTL',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'MAESTER_OBJECTS_TTL_IN_SECONDS',
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
                }
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
              volumes: [
                {
                  configMap: {
                    name: redisConfigMapName
                  },
                  name: 'config'
                }
              ]
            },
          },
          strategy: {
            type: 'RollingUpdate',
            rollingUpdate: {
              maxUnavailable: 1,
              maxSurge: 1,
            },
          }
        },
      },
      {
            apiVersion: 'batch/v1beta1',
            kind: 'CronJob',
            metadata: {
              name: 'remove-expired-objects',
              namespace: 'platform',
              labels: {
                app: appName,
                subapp: 'remove-expired-objects',
              },
            },
            spec: {
              schedule: '0 * * * *',
              concurrencyPolicy: 'Forbid',
              failedJobsHistoryLimit: 1,
              successfulJobsHistoryLimit: 3,
              startingDeadlineSeconds: 600,
              jobTemplate: {
                metadata: {
                  labels: {
                    app: appName,
                    subapp: 'remove-expired-objects',
                  },
                },
                spec: {
                  template: {
                    metadata: {
                      labels: {
                        app: appName,
                        subapp: 'remove-expired-objects',
                      },
                    },
                    spec: {
                      containers: [
                        {
                          name: 'remove-expired-objects',
                          image: 'elasticio/maester:' + version,
                          args: [
                            'npm',
                            'run',
                            'jobs'
                          ],
                          env: [
                            {
                              name: 'APP_NAME',
                              value: appName + ':remove-expired-objects',
                            },
                            {
                              name: 'LOG_LEVEL',
                              value: 'info'
                            },
                            {
                              name: 'OBJECTS_TTL',
                              valueFrom: {
                                secretKeyRef: {
                                  name: 'elasticio',
                                  key: 'MAESTER_OBJECTS_TTL_IN_SECONDS',
                                },
                              },
                            },
                          ],
                          envFrom: [
                            {
                              secretRef: {
                                name: 'elasticio',
                              },
                            },
                          ],
                        },
                      ],
                      imagePullSecrets: [
                        {
                          name: 'elasticiodevops',
                        },
                      ],
                      restartPolicy: 'OnFailure',
                      nodeSelector: {
                        'elasticio-role': 'platform',
                      },
                    },
                  },
                },
              }
            },
          }
    ]
}
