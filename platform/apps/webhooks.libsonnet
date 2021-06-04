local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(name, replicas):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'webhooks',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            'app.kubernetes.io/managed-by': 'Helm',
             app: 'webhooks'
          }
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'webhooks',
            },
          },
          template: {
            metadata: {
              name: 'webhooks',
              labels: {
                app: 'webhooks',
              },
            },
            spec: podAffinitySpreadNodes.call('webhooks') + {
              containers: [
                {
                  name: 'webhooks',
                  image: 'elasticio/webhooks:' + version,
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
                      value: 'webhooks',
                    },
                    {
                      name: 'PORT_GATEWAY',
                      value: '5000',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                  ],
                  livenessProbe: {
                    httpGet: {
                      port: 5000,
                      path: '/healthcheck',
                    },
                    initialDelaySeconds: 60,
                    periodSeconds: 15,
                    failureThreshold: 5,
                    successThreshold: 1,
                    timeoutSeconds: 15,
                  },
                  readinessProbe: {
                    httpGet: {
                      port: 5000,
                      path: '/healthcheck',
                    },
                    initialDelaySeconds: 60,
                    periodSeconds: 15,
                    failureThreshold: 5,
                    successThreshold: 1,
                    timeoutSeconds: 15,
                  },
                  ports: [
                    {
                      containerPort: 5000,
                      protocol: 'TCP',
                    },
                  ],
                  resources: {
                    limits: {
                      memory: '512Mi',
                      cpu: 1,
                    },
                    requests: {
                      memory: '512Mi',
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
          name: 'webhooks-service',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            'app.kubernetes.io/managed-by': 'Helm',
            app: 'webhooks-service',
          }
        },
        spec: {
          type: 'ClusterIP',
          sessionAffinity: 'None',
          ports: [
            {
              name: '5000',
              port: 5000,
              protocol: 'TCP',
              targetPort: 5000,
              nodePort: null,
            },
          ],
          selector: {
            app: 'webhooks',
          },
        },
        status: {
          loadBalancer: {},
        },
      },
    ]
}
