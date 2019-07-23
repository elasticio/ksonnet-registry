local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(replicas):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'steward',
          namespace: 'platform',
          labels: {
            app: 'steward',
          },
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'steward',
            },
          },
          template: {
            metadata: {
              name: 'steward',
              labels: {
                app: 'steward',
              },
            },
            spec: podAffinitySpreadNodes.call('steward') + {
              containers: [
                {
                  name: 'steward',
                  image: 'elasticio/steward:' + version,
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
                      value: 'steward',
                    },
                    {
                      name: 'PORT',
                      value: '3000',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                    {
                      name: 'BASE_URL',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'EXTERNAL_STEWARD_URI',
                        },
                      },
                    },
                    {
                      name: 'STORAGE_URL',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'STEWARD_STORAGE_URI',
                        },
                      },
                    },
                    {
                      name: 'STORAGE_URL_1',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'STEWARD_STORAGE_URI_1',
                          optional: true,
                        },
                      },
                    },
                  ],
                  livenessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 3,
                    httpGet: {
                      port: 3000,
                      path: '/',
                    },
                  },
                  resources: {
                    limits: {
                      memory: '512Mi',
                      cpu: 0.5,
                    },
                    requests: {
                      memory: '256Mi',
                      cpu: 0.2,
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
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          labels: {
            app: 'steward-service',
          },
          name: 'steward-service',
          namespace: 'platform',
        },
        spec: {
          type: 'ClusterIP',
          sessionAffinity: 'None',
          ports: [
            {
              name: '8200',
              port: 8200,
              protocol: 'TCP',
              targetPort: 3000,
              nodePort: null,
            },
          ],
          selector: {
            app: 'steward',
          },
        },
        status: {
          loadBalancer: {},
        },
      },
    ]
}
