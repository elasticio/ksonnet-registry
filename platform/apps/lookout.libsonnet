local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(replicas):: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'lookout',
        namespace: 'platform',
        labels: {
          app: 'lookout',
        },
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
                  },
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
    }
}
