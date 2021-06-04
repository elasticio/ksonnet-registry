local version = import 'elasticio/platform/version.json';

{
  app(name):: {
      kind: 'Deployment',
      apiVersion: 'apps/v1',
      metadata: {
        name: 'scheduler',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'scheduler',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: 'scheduler',
          },
        },
        template: {
          metadata: {
            name: 'scheduler',
            labels: {
              app: 'scheduler',
            },
          },
          spec: {
            containers: [
              {
                name: 'scheduler',
                image: 'elasticio/scheduler:' + version,
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
                    value: 'scheduler',
                  },
                  {
                    name: 'PORT_SCHEDULER',
                    value: '5001',
                  },
                  {
                    name: 'LOG_LEVEL',
                    value: 'trace',
                  },
                ],
                livenessProbe: {
                  httpGet: {
                    port: 5001,
                    path: '/',
                  },
                  initialDelaySeconds: 60,
                  periodSeconds: 10,
                  failureThreshold: 5,
                  successThreshold: 1,
                  timeoutSeconds: 5,
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
