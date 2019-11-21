local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

local readService = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    labels: {
      app: 'bran-read-service',
    },
    name: 'bran-read-service',
    namespace: 'platform',
  },
  spec: {
    selector: {
      app: 'bran-read',
    },
    ports: [
      {
        name: '5961',
        port: 5961,
        protocol: 'TCP'
      },
    ]
  },
};

local app(replicas, mode) = [
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'bran-' + mode,
      namespace: 'platform',
      labels: {
        app: 'bran-' + mode
      }
    },
    spec: {
      replicas: replicas,
      selector: {
        matchLabels: {
          app: 'bran-' + mode
        }
      },
      template: {
        metadata: {
          name: 'bran-' + mode,
          labels: {
            app: 'bran-' + mode
          }
        },
        spec: podAffinitySpreadNodes.call('bran-' + mode) + {
          containers: [
            {
              name: 'bran-' + mode,
              image: 'elasticio/bran:' + version,
              envFrom: [
                {
                  secretRef: {
                    name: 'elasticio'
                  }
                }
              ],
              env: [
                {
                  name: 'APP_NAME',
                  value: 'bran-' + mode
                },
                {
                  name: 'BRAN_MODE',
                  value: mode
                },
                {
                  name: 'LOG_LEVEL',
                  value: 'info'
                },
                {
                  name: 'PREFETCH_COUNT',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'elasticio',
                      key: 'BRAN_PREFETCH_COUNT'
                    }
                  }
                }
              ],
              livenessProbe: {
                httpGet: {
                  port: 5961,
                  path: 'v1/healthcheck'
                },
                initialDelaySeconds: 60,
                periodSeconds: 10,
                failureThreshold: 5,
                successThreshold: 1,
                timeoutSeconds: 5
              },
              resources: {
                limits: {
                  memory: '2048Mi',
                  cpu: 2
                },
                requests: {
                  memory: '512Mi',
                  cpu: 0.1
                }
              },
              terminationMessagePath: '/dev/termination-log',
              terminationMessagePolicy: 'File',
              imagePullPolicy: 'Always',
              securityContext: {
                privileged: false
              }
            }
          ],
          imagePullSecrets: [
            {
              name: 'elasticiodevops'
            }
          ],
          restartPolicy: 'Always',
          terminationGracePeriodSeconds: 30,
          nodeSelector: {
            'elasticio-role': 'platform'
          }
        }
      },
      strategy: {
        type: 'RollingUpdate',
        rollingUpdate: {
          maxUnavailable: 1,
          maxSurge: 1
        }
      }
    }
  }
];

{
  app(replicas, mode)::
    app(replicas, mode) + (if mode == 'write' then [] else [readService])
}
