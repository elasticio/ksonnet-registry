local version = import 'elasticio/platform/version.json';
local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
{
  app(accessKey, secretKey):: [
    {
      kind: 'Deployment',
      apiVersion: 'apps/v1',
      metadata: {
        name: 's3',
        namespace: 'platform',
        labels: {
          app: 's3',
        },
      },
      spec: {
        replicas: 2,
        selector: {
          matchLabels: {
            app: 's3',
          },
        },
        template: {
          metadata: {
            name: 's3',
            annotations: {
              "prometheus.io/scrape": "true",
              "prometheus.io/port": "3000",
              "prometheus.io/path": "/minio/prometheus/metrics"
            },
            labels: {
              app: 's3',
            },
          },
          spec: podAffinitySpreadNodes.call('s3') + {
            containers: [
              {
                name: 's3',
                image: 'elasticio/minio:' + version,
                command: [
                  'minio', 'server', '/data'
                ],
                env: [
                  {
                    name: 'MINIO_PROMETHEUS_AUTH_TYPE',
                    value: 'public'
                  },
                  {
                    name: 'MINIO_ACCESS_KEY',
										value: accessKey
                  },
                  {
                    name: 'MINIO_SECRET_KEY',
										value: secretKey,
                  }
                ],
                livenessProbe: {
                  httpGet: {
                    port: 9000,
                    path: '/minio/health/live',
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
                    path: '/minio/health/ready',
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
                    cpu: 2,
                  },
                  requests: {
                    memory: '512Mi',
                    cpu: 0.5,
                  },
                },
                volumeMounts: [
									{
                  	mountPath: '/data',
                    name: 's3-storage'
									}
								],
                terminationMessagePath: '/dev/termination-log',
                terminationMessagePolicy: 'File',
                imagePullPolicy: 'Always',
                securityContext: {
                  privileged: false
                }
              }
            ],
            imagePullSecrets: [
              {
                name: 'elasticiodevops'
              }
            ],
            volumes: [
							{
              	name: 's3-storage',
                persistentVolumeClaim: {
                	claimName: 'platform-storage-slugs-volume-claim'
                }
              }
						],
            restartPolicy: 'Always',
            nodeSelector: {
              'elasticio-role': 'platform'
            }
          }
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
          app: 's3-service',
        },
        name: 's3-service',
        namespace: 'platform',
      },
      spec: {
        type: 'ClusterIP',
        ports: [{
          name: '3000',
          port: 3000,
          protocol: 'TCP',
          targetPort: 9000
        }],
        selector: {
          app: 's3'
        },
        sessionAffinity: 'None'
      }
		}
  ]
}
