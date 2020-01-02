local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(replicas, cpuRequest=0.1, cpuLimit=1, terminationGracePeriodSeconds=30):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'api',
          namespace: 'platform',
          labels: {
            app: 'api',
          },
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'api',
            },
          },
          template: {
            metadata: {
              name: 'api',
              annotations: {
                "prometheus.io/scrape": "true",
                "prometheus.io/port": "9000"
              },
              labels: {
                app: 'api',
              },
            },
            spec: podAffinitySpreadNodes.call('api') + {
              containers: [
                {
                  name: 'api',
                  image: 'elasticio/api:' + version,
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
                      value: 'api',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'info',
                    },
                    {
                      name: 'PORT_API',
                      value: '9000',
                    },
                    {
                      name: 'MARATHON_URI',
                      value: 'http://mazafaka.io/this-env-var-is-deprecated-but-still-required-by-v1',
                    },
                    {
                      name: 'TERMINATION_DELAY',
                      value: std.toString(terminationGracePeriodSeconds / 2)
                    },
                  ],
                  livenessProbe: {
                    httpGet: {
                      port: 9000,
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
                      port: 9000,
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
                      containerPort: 9000,
                      protocol: 'TCP',
                    },
                  ],
                  resources: {
                    limits: {
                      memory: '2048Mi',
                      cpu: cpuLimit,
                    },
                    requests: {
                      memory: '512Mi',
                      cpu: cpuRequest,
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
            app: 'api-service',
          },
          name: 'api-service',
          namespace: 'platform',
        },
        spec: {
          type: 'ClusterIP',
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
            app: 'api',
          },
          sessionAffinity: 'None',
        },
      },
    ]
}
