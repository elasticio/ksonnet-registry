local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(replicas):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'raven',
          namespace: 'platform',
          labels: {
            app: 'raven',
          },
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'raven',
            },
          },
          template: {
            metadata: {
              name: 'raven',
              annotations: {
                'prometheus.io/scrape': 'true',
                'prometheus.io/port': '3000'
              },
              labels: {
                app: 'raven',
              },
            },
            spec: podAffinitySpreadNodes.call('raven') + {
              containers: [
                {
                  name: 'raven',
                  image: 'elasticio/raven:' + version,
                  envFrom: [
                    {
                      secretRef: {
                        name: 'elasticio',
                      },
                    },
                  ],
                  env: [
                    {
                      name: 'RAVEN_PORT',
                      value: '3000',
                    },
                  ],
                  livenessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 3,
                    httpGet: {
                      port: 3000,
                      path: '/healthcheck',
                    },
                  },
                  readinessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 3,
                    httpGet: {
                      port: 3000,
                      path: '/healthcheck',
                    },
                  },
                  ports: [
                    {
                      containerPort: 3000,
                      protocol: 'TCP',
                    },
                  ],
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
          labels: {
            app: 'raven-service',
          },
          name: 'raven-service',
          namespace: 'platform',
        },
        spec: {
          type: 'ClusterIP',
          sessionAffinity: 'None',
          ports: [
            {
              name: '8070',
              port: 8070,
              protocol: 'TCP',
              targetPort: 3000,
              nodePort: null,
            },
          ],
          selector: {
            app: 'raven',
          },
        },
      },
    ]
}
