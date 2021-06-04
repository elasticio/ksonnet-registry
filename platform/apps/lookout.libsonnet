local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(name, replicas, maxErrorRecordsCount = "1000"):: [
    {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'lookout',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'lookout',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        replicas: replicas,
        selector: {
          matchLabels: {
            app: 'lookout',
          },
        },
        template: {
          metadata: {
            name: 'lookout',
            labels: {
              app: 'lookout',
            },
          },
          spec: podAffinitySpreadNodes.call('lookout') + {
            containers: [
              {
                name: 'lookout',
                image: 'elasticio/lookout:' + version,
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
                    value: 'lookout',
                  },
                  {
                    name: 'LOG_LEVEL',
                    value: 'trace',
                  },
                  {
                    name: 'PREFETCH_COUNT',
                    valueFrom: {
                      secretKeyRef: {
                        name: 'elasticio',
                        key: 'LOOKOUT_PREFETCH_COUNT',
                      },
                    },
                  }
                ],
                livenessProbe: {
                  httpGet: {
                    port: 10000,
                    path: '/healthcheck',
                  },
                  initialDelaySeconds: 60,
                  periodSeconds: 10,
                  failureThreshold: 5,
                  successThreshold: 1,
                  timeoutSeconds: 5,
                },
                resources: {
                  limits: {
                    memory: '2048Mi',
                    cpu: 2,
                  },
                  requests: {
                    memory: '512Mi',
                    cpu: 1,
                  },
                },
                terminationMessagePath: '/dev/termination-log',
                terminationMessagePolicy: 'File',
                imagePullPolicy: 'Always',
                securityContext: {
                  privileged: false,
                },
              },
            ],
            imagePullSecrets: [
              {
                name: 'elasticiodevops',
              },
            ],
            restartPolicy: 'Always',
            terminationGracePeriodSeconds: 30,
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
    },
    {
      apiVersion: 'batch/v1beta1',
      kind: 'CronJob',
      metadata: {
        name: 'remove-excess-error-records',
        namespace: 'platform',
        labels: {
          app: 'lookout',
          subapp: 'remove-excess-error-records',
          'app.kubernetes.io/managed-by': 'Helm'
        },
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        }
      },
      spec: {
        schedule: '*/3 * * * *',
        concurrencyPolicy: 'Forbid',
        failedJobsHistoryLimit: 1,
        successfulJobsHistoryLimit: 3,
        startingDeadlineSeconds: 600,
        jobTemplate: {
          metadata: {
            labels: {
              app: 'lookout',
              subapp: 'remove-excess-error-records',
            },
          },
          spec: {
            template: {
              metadata: {
                labels: {
                  app: 'lookout',
                  subapp: 'remove-excess-error-records',
                },
              },
              spec: {
                containers: [
                  {
                    name: 'remove-excess-error-records',
                    image: 'elasticio/lookout:' + version,
                    args: [
                      'npm',
                      'run',
                      'jobs'
                    ],
                    env: [
                      {
                        name: 'APP_NAME',
                        value: 'lookout:remove-excess-error-records',
                      },
                      {
                        name: 'MAX_ERROR_RECORDS_COUNT',
                        value: maxErrorRecordsCount
                      }
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
