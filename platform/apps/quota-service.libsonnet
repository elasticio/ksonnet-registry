local version = import 'elasticio/platform/version.json';

{
  app(secretName, version)::[
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'quota-service',
          namespace: 'platform',
          labels: {
            app: 'quota-service',
          },
        },
        spec: {
          replicas: 2,
          selector: {
            matchLabels: {
              app: 'quota-service',
            },
          },
          template: {
            metadata: {
              name: 'quota-service',
              labels: {
                app: 'quota-service',
              },
            },
            spec: {
              containers: [
                {
                  name: 'quota-service',
                  image: 'elasticio/quota-service:' + version,
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
                      value: 'quota-service',
                    },
                    {
                      name: 'PORT',
                      value: '3002',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'info',
                    },
                    {
                      name: 'MONGO_URI',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'QUOTA_SERVICE_MONGO_URI',
                        },
                      },
                    },
                  ],
                  livenessProbe: {
                    httpGet: {
                      port: 3002,
                      path: '/healthcheck',
                    },
                    initialDelaySeconds: 10,
                    periodSeconds: 3,
                    failureThreshold: 3,
                    successThreshold: 1,
                  },
                  resources: {
                    limits: {
                      memory: '512Mi',
                      cpu: 1,
                    },
                    requests: {
                      memory: '256Mi',
                      cpu: 0.5,
                    },
                  },
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File',
                  imagePullPolicy: 'IfNotPresent',
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
            app: 'quota-service-service',
          },
          name: 'quota-service-service',
          namespace: 'platform',
        },
        spec: {
          type: 'NodePort',
          selector: {
            app: 'quota-service',
          },
          ports: [
            {
              name: '3002',
              port: 3002,
              protocol: 'TCP',
              targetPort: 3002,
            },
          ],
        },
      },
    ]
}
