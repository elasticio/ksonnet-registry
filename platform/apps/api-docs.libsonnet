{
  app(name, image):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'api-docs',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            app: 'api-docs',
            'app.kubernetes.io/managed-by': 'Helm'
          }
        },
        spec: {
          replicas: 1,
          selector: {
            matchLabels: {
              app: 'api-docs',
            },
          },
          template: {
            metadata: {
              name: 'api-docs',
              labels: {
                app: 'api-docs',
              },
            },
            spec: {
              containers: [{
                name: 'api-docs',
                image: image,
                envFrom: [],
                env: [],
                livenessProbe: {
                  initialDelaySeconds: 10,
                  periodSeconds: 3,
                  httpGet: {
                    port: 8000,
                    path: '/healthcheck',
                  },
                },
                readinessProbe: {
                  initialDelaySeconds: 10,
                  periodSeconds: 3,
                  httpGet: {
                    port: 8000,
                    path: '/healthcheck',
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
                imagePullPolicy: 'IfNotPresent',
                securityContext: {
                  privileged: false,
                },
              }],
              imagePullSecrets: [{
                name: 'elasticiodevops',
              }],
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
          name: 'api-docs-service',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            app: 'api-docs-service',
            'app.kubernetes.io/managed-by': 'Helm'
          }
        },
        spec: {
          type: 'ClusterIP',
          sessionAffinity: 'None',
          ports: [
            {
              name: '8000',
              port: 8000,
              protocol: 'TCP',
              targetPort: 8000,
              nodePort: null,
            },
          ],
          selector: {
            app: 'api-docs',
          },
        },
      },
    ]
}
