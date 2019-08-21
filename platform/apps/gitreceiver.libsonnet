local version = import 'elasticio/platform/version.json';

{
  app(dockerRegistryUri):: [
      {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
          name: 'gitreceiver',
          namespace: 'platform',
          labels: {
            app: 'gitreceiver',
          },
        },
        spec: {
          replicas: 1,
          selector: {
            matchLabels: {
              app: 'gitreceiver',
            },
          },
          template: {
            metadata: {
              name: 'gitreceiver',
              labels: {
                app: 'gitreceiver',
              },
            },
            spec: {
              containers: [
                {
                  name: 'gitreceiver',
                  image: 'elasticio/gitreceiver:' + version,
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
                      value: 'gitreceiver',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                    {
                      name: 'APPBUILDER_IMAGE',
                      value: 'elasticio/appbuilder:production',
                    },
                    {
                      name: 'GIT_BRANCH',
                      value: 'master',
                    },
                    {
                      name: 'WEBDAV_URL',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'SLUG_BASE_URL',
                        },
                      },
                    },
                    {
                      name: 'WEBDAV_URL_1',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'SECONDARY_SLUG_STORAGE',
                          optional: true,
                        },
                      },
                    },
                    {
                      name: 'GELF_ADDRESS',
                      value: '$(GELF_PROTOCOL)://$(GELF_HOST):$(GELF_PORT)',
                    },
                    {
                      name: 'PRIVATE_KEY_PATH',
                      value: '/etc/gitreceiver/private-key/key',
                    },
                    {
                      name: 'DOCKER_REGISTRY_URI',
                      value: dockerRegistryUri
                    }
                  ],
                  livenessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 20,
                    tcpSocket: {
                      port: 4022,
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
                    privileged: true,
                  },
                  volumeMounts: [
                    {
                      name: 'docker-sock',
                      mountPath: '/var/run/docker.sock',
                    },
                    {
                      name: 'private-key',
                      mountPath: '/etc/gitreceiver/private-key',
                    },
                  ],
                },
              ],
              volumes: [
                {
                  name: 'docker-sock',
                  hostPath: {
                    path: '/var/run/docker.sock',
                    type: 'File',
                  },
                },
                {
                  name: 'private-key',
                  secret: {
                    secretName: 'gitreceiver-private-key',
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
            app: 'gitreceiver-service',
          },
          name: 'gitreceiver-service',
          namespace: 'platform',
        },
        spec: {
          type: 'ClusterIP',
          sessionAffinity: 'None',
          selector: {
            app: 'gitreceiver',
          },
          ports: [
            {
              name: '4022',
              port: 4022,
              protocol: 'TCP',
              targetPort: 4022,
              nodePort: null,
            },
          ],
        },
      },
    ]
}
