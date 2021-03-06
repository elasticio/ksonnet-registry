local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

local readService(name) = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'bran-read-service',
    namespace: 'platform',
    annotations: {
      'meta.helm.sh/release-name': name,
      'meta.helm.sh/release-namespace': 'default'
    },
    labels: {
      app: 'bran-read-service',
      'app.kubernetes.io/managed-by': 'Helm'
    }
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

local app(name, replicas, mode) = [
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'bran-' + mode,
      namespace: 'platform',
      labels: {
        app: 'bran-' + mode,
        'app.kubernetes.io/managed-by': 'Helm'
      },
      annotations: {
        'meta.helm.sh/release-name': name,
        'meta.helm.sh/release-namespace': 'default'
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
          annotations: {
            "prometheus.io/scrape": "true",
            "prometheus.io/port": "5961"
          },
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
                },
                {
                  name: 'CLICKHOUSE_NO_REPLICA',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'elasticio',
                      key: 'BRAN_CLICKHOUSE_NO_REPLICA',
                    },
                  },
                }
              ],
              ports: [{
                containerPort: 5961
              }],
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
  app(name, replicas, mode)::
    app(name, replicas, mode) + (if mode == 'write' then [] else [readService(name)])
}
