local k = import 'k.libsonnet';

{
  app(
    terminationGracePeriodSeconds = 30,
    redisPort = 6379,
    appName = 'cache',
    configMapName = appName + '-configmap',
    redisMaxMemGB = 1
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
                      port: redisPort,
                      protocol: 'TCP',
                      targetPort: redisPort
                  }
              ],
              selector: {
                  app: appName
              }
          }
      },
      {
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: configMapName,
          namespace: 'platform',
          labels: {
            app: appName,
          },
        },
        data: {
          "redis.conf": |||
              # disabling snapshotting as we currently don't know how to deal with persistence
              save ""
              maxmemory %(maxMem)dgb
              maxmemory-policy allkeys-lru
          ||| % { maxMem: redisMaxMemGB }
        },
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
          replicas: 1,
          selector: {
            matchLabels: {
              app: appName,
            },
          },
          template: {
            metadata: {
              name: appName,
              annotations: {
                "prometheus.io/scrape": "true",
                "prometheus.io/port": "9121"
              },
              labels: {
                app: appName,
              }
            },
            spec: {
              containers: [
                {
                  name: 'redis',
                  image: 'redis:5.0.7-alpine',
                  args: [
                    '/readonly-config/redis.conf',
                    '--requirepass',
                    '$(CACHE_REDIS_PASSWORD)'
                  ],
                  env: [
                    {
                      name: 'CACHE_REDIS_PASSWORD',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'CACHE_REDIS_PASSWORD',
                        },
                      },
                    },
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
                },
                {
                  name: 'redis-exporter',
                  image: 'oliver006/redis_exporter:v1.15.1-alpine',
                  args: [
                    '--redis.password',
                    '$(CACHE_REDIS_PASSWORD)'
                  ],
                  env: [
                    {
                      name: 'CACHE_REDIS_PASSWORD',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'CACHE_REDIS_PASSWORD',
                        },
                      },
                    },
                  ],
                  ports: [{
                    containerPort: 9121
                  }],
                  resources: {
                    limits: {
                      cpu: 0.2,
                      memory: '256Mi'
                    },
                    requests: {
                      cpu: 0.1,
                      memory: '128Mi'
                    }
                  }
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
                    name: configMapName
                  },
                  name: 'config'
                }
              ]
            },
          }
        },
      }
    ]
}
