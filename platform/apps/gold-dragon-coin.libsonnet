local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(name, replicas):: [
      {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
          name: 'gold-dragon-coin',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            app: 'gold-dragon-coin',
            'app.kubernetes.io/managed-by': 'Helm'
          }
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'gold-dragon-coin',
            },
          },
          template: {
            metadata: {
              name: 'gold-dragon-coin',
              labels: {
                app: 'gold-dragon-coin',
              },
            },
            spec: podAffinitySpreadNodes.call('gold-dragon-coin') + {
              containers: [
                {
                  name: 'gold-dragon-coin',
                  image: 'elasticio/gold-dragon-coin:' + version,
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
                      value: 'gold-dragon-coin',
                    },
                    {
                      name: 'ENFORCE',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'ENFORCE_QUOTA',
                        },
                      },
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                    {
                      name: 'PORT',
                      value: '9000',
                    },
                  ],
                  livenessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 3,
                    httpGet: {
                      port: 9000,
                      path: '/health-check',
                    },
                  },
                  resources: {
                    limits: {
                      memory: '512Mi',
                      cpu: 0.5,
                    },
                    requests: {
                      memory: '256Mi',
                      cpu: 0.1,
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
          name: 'gold-dragon-coin-service',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            app: 'gold-dragon-coin-service',
            'app.kubernetes.io/managed-by': 'Helm'
          }
        },
        spec: {
          type: 'ClusterIP',
          sessionAffinity: 'None',
          ports: [
            {
              name: '9000',
              port: 9000,
              protocol: 'TCP',
              targetPort: 9000,
              nodePort: null,
            },
          ],
          selector: {
            app: 'gold-dragon-coin',
          },
        },
      },
    ]
}
