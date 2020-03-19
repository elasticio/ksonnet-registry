local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(replicas, terminationGracePeriodSeconds=30):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'frontend',
          namespace: 'platform',
          labels: {
            app: 'frontend',
          },
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'frontend',
            },
          },
          template: {
            metadata: {
              name: 'frontend',
              annotations: {
                "prometheus.io/scrape": "true",
                "prometheus.io/port": "8000"
              },
              labels: {
                app: 'frontend',
              },
            },
            spec: podAffinitySpreadNodes.call('frontend') + {
              containers: [
                {
                  name: 'frontend',
                  image: 'elasticio/frontend:' + version,
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
                      value: 'frontend',
                    },
                    {
                      name: 'PORT',
                      value: '8000',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                    {
                      name: 'ELASTICIO_API_URI',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'API_URI',
                        },
                      },
                    },
                    {
                      name: 'FRONTEND_URI',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'EXTERNAL_APP_URI',
                        },
                      },
                    },
                    {
                      name: 'EXECUTIONS_ENABLED',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'BRAN_ENABLED',
                        },
                      },
                    },
                    {
                      name: 'TERMINATION_DELAY',
                      value: std.toString(terminationGracePeriodSeconds / 2)
                    },
                  ],
                  livenessProbe: {
                    httpGet: {
                      port: 8000,
                      path: '/backend/healthcheck',
                    },
                    initialDelaySeconds: 60,
                    periodSeconds: 15,
                    failureThreshold: 5,
                    successThreshold: 1,
                    timeoutSeconds: 15,
                  },
                  readinessProbe: {
                    httpGet: {
                      port: 8000,
                      path: '/backend/healthcheck',
                    },
                    initialDelaySeconds: 60,
                    periodSeconds: 15,
                    failureThreshold: 5,
                    successThreshold: 1,
                    timeoutSeconds: 15,
                  },
                  ports: [
                    {
                      containerPort: 8000,
                      protocol: 'TCP',
                    },
                  ],
                  resources: {
                    limits: {
                      memory: '2048Mi',
                      cpu: 2,
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
              terminationGracePeriodSeconds: terminationGracePeriodSeconds,
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
            app: 'frontend-service',
          },
          name: 'frontend-service',
          namespace: 'platform',
        },
        spec: {
          type: 'ClusterIP',
          ports: [
            {
              port: 8000,
              protocol: 'TCP',
              targetPort: 8000,
              nodePort: null,
            },
          ],
          selector: {
            app: 'frontend',
          },
        },
      },
    ]
}
