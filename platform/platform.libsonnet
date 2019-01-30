local k = import 'k.libsonnet';
local version = import 'elasticio/platform/version.json';
{
  parts:: {
    pullSecret(username, password, email, registry='https://index.docker.io/v1/'):: k.core.v1.secret.new(
      name='elasticiodevops',
      data={
        '.dockerconfigjson': std.base64(std.toString({
          auths: {
            [registry]: {
              username: username,
              password: password,
              email: email,
              auth: std.base64(std.toString(username + ':' + password)),
            },
          }
        })),
      },
      type='kubernetes.io/dockerconfigjson'
    ).withNamespace('platform'),
    tlsSecret(name, crt, key):: k.core.v1.secret.new(
      name=name,
      data={
        'tls.crt': crt,
        'tls.key': key,
      },
      type='kubernetes.io/tls'
    ).withNamespace('platform'),
    gitreceiverKey(key):: k.core.v1.secret.new(
      name='gitreceiver-private-key',
      data={
        key: key,
      }
    ).withNamespace('platform'),
    admiral():: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'admiral',
          namespace: 'platform',
          labels: {
            app: 'admiral',
          },
        },
        spec: {
          replicas: 1,
          selector: {
            matchLabels: {
              app: 'admiral',
            },
          },
          template: {
            metadata: {
              name: 'admiral',
              labels: {
                app: 'admiral',
              },
            },
            spec: {
              containers: [
                {
                  name: 'admiral',
                  image: 'elasticio/admiral:' + version,
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
                      value: 'admiral',
                    },
                    {
                      name: 'PORT_ADMIRAL',
                      value: '12000',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'debug',
                    },
                    {
                      name: 'RABBITMQ_URI',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'AMQP_URI',
                        },
                      },
                    },
                    {
                      name: 'KUBERNETES_TASKS_NODE_LABEL_KEY',
                      value: 'elasticio-role',
                    },
                    {
                      name: 'KUBERNETES_TASKS_NODE_LABEL_VALUE',
                      value: 'tasks',
                    },
                  ],
                  livenessProbe: {
                    httpGet: {
                      port: 12000,
                      path: '/healthcheck',
                    },
                    initialDelaySeconds: 60,
                    periodSeconds: 10,
                    failureThreshold: 5,
                    successThreshold: 1,
                    timeoutSeconds: 5,
                  },
                  resources: {
                    limits: {
                      memory: '2048Mi',
                      cpu: 2,
                    },
                    requests: {
                      memory: '512Mi',
                      cpu: 1,
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
              serviceAccountName: 'admiral-account',
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
        kind: 'ServiceAccount',
        metadata: {
          name: 'admiral-account',
          namespace: 'platform',
        },
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'Role',
        metadata: {
          name: 'admiral-role',
          namespace: 'tasks',
        },
        rules: [
          {
            apiGroups: [
              '',
              'batch',
            ],
            resources: [
              'jobs',
              'pods'
            ],
            verbs: [
              'create',
              'delete',
              'deletecollection',
              'get',
              'list',
              'patch',
              'update',
              'watch',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'configmaps',
            ],
            verbs: [
              'get',
              'list',
            ],
          },
        ],
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'RoleBinding',
        metadata: {
          name: 'admiral-rolebinding',
          namespace: 'tasks',
        },
        roleRef: {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'Role',
          name: 'admiral-role',
        },
        subjects: [
          {
            kind: 'ServiceAccount',
            name: 'admiral-account',
            namespace: 'platform',
          },
        ],
      },
    ],
    apiDocs(image):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'api-docs',
          namespace: 'platform',
          labels: {
            app: 'api-docs',
          },
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
          labels: {
            app: 'api-docs-service',
          },
        },
        spec: {
          ports: [
            {
              name: '8000',
              port: 8000,
              protocol: 'TCP',
              targetPort: 8000,
            },
          ],
          selector: {
            app: 'api-docs',
          },
          type: 'NodePort',
        },
      },
    ],
    api(replicas):: [
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
              labels: {
                app: 'api',
              },
            },
            spec: {
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
            app: 'api-service',
          },
          name: 'api-service',
          namespace: 'platform',
        },
        spec: {
          externalTrafficPolicy: 'Cluster',
          ports: [
            {
              name: '9000',
              port: 9000,
              protocol: 'TCP',
              targetPort: 9000,
            },
          ],
          selector: {
            app: 'api',
          },
          sessionAffinity: 'None',
          type: 'NodePort',
        },
      },
    ],
    fluentd():: [
      {
        apiVersion: 'v1',
        kind: 'ServiceAccount',
        metadata: {
          name: 'eio-fluentd-account',
          namespace: 'platform',
        },
      },
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'DaemonSet',
        metadata: {
          labels: {
            app: 'eio-fluentd',
          },
          name: 'eio-fluentd',
          namespace: 'platform',
        },
        spec: {
          selector: {
            matchLabels: {
              app: 'eio-fluentd',
            },
          },
          template: {
            metadata: {
              labels: {
                app: 'eio-fluentd',
              },
            },
            spec: {
              containers: [
                {
                  envFrom: [
                    {
                      secretRef: {
                        name: 'elasticio',
                      },
                    },
                  ],
                  image: 'elasticio/fluentd-kubernetes-gelf',
                  imagePullPolicy: 'Always',
                  name: 'eio-fluentd',
                  resources: {
                    limits: {
                      memory: '512Mi',
                    },
                    requests: {
                      cpu: '100m',
                      memory: '256Mi',
                    },
                  },
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File',
                  volumeMounts: [
                    {
                      mountPath: '/var/log',
                      name: 'varlog',
                    },
                    {
                      mountPath: '/var/lib/docker/containers',
                      name: 'varlibdockercontainers',
                      readOnly: true,
                    },
                  ],
                },
              ],
              serviceAccountName: 'eio-fluentd-account',
              dnsPolicy: 'ClusterFirst',
              restartPolicy: 'Always',
              securityContext: {},
              terminationGracePeriodSeconds: 30,
              volumes: [
                {
                  hostPath: {
                    path: '/var/log',
                    type: '',
                  },
                  name: 'varlog',
                },
                {
                  hostPath: {
                    path: '/var/lib/docker/containers',
                    type: '',
                  },
                  name: 'varlibdockercontainers',
                },
              ],
            },
          },
          updateStrategy: {
            rollingUpdate: {
              maxUnavailable: 1,
            },
            type: 'RollingUpdate',
          },
        },
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'ClusterRole',
        metadata: {
          name: 'eio-fluentd-role',
        },
        rules: [
          {
            apiGroups: [
              '',
            ],
            resources: [
              'pods',
            ],
            verbs: [
              'get',
              'list',
              'watch',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'namespaces',
            ],
            verbs: [
              'get',
              'list',
              'watch',
            ],
          },
        ],
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'ClusterRoleBinding',
        metadata: {
          name: 'eio-fluentd-rolebinding',
        },
        roleRef: {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'ClusterRole',
          name: 'eio-fluentd-role',
        },
        subjects: [
          {
            kind: 'ServiceAccount',
            name: 'eio-fluentd-account',
            namespace: 'platform',
          },
        ],
      },
    ],
    frontend(replicas):: [
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
              labels: {
                app: 'frontend',
              },
            },
            spec: {
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
            app: 'frontend-service',
          },
          name: 'frontend-service',
          namespace: 'platform',
        },
        spec: {
          externalTrafficPolicy: 'Cluster',
          ports: [
            {
              port: 8000,
              protocol: 'TCP',
              targetPort: 8000,
            },
          ],
          selector: {
            app: 'frontend',
          },
          type: 'NodePort',
        },
      },
    ],
    gitreceiver():: [
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
          type: 'NodePort',
          selector: {
            app: 'gitreceiver',
          },
          ports: [
            {
              name: '4022',
              port: 4022,
              protocol: 'TCP',
              targetPort: 4022,
            },
          ],
        },
      },
    ],
    goldDagonCoin(replicas):: [
      {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
          name: 'gold-dragon-coin',
          namespace: 'platform',
          labels: {
            app: 'gold-dragon-coin',
          },
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
            spec: {
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
          labels: {
            app: 'gold-dragon-coin-service',
          },
          name: 'gold-dragon-coin-service',
          namespace: 'platform',
        },
        spec: {
          ports: [
            {
              name: '9000',
              port: 9000,
              protocol: 'TCP',
              targetPort: 9000,
            },
          ],
          selector: {
            app: 'gold-dragon-coin',
          },
          type: 'ClusterIP',
        },
      },
    ],
    ingressController():: [
      {
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          labels: {
            app: 'ingress-nginx',
          },
          name: 'nginx-configuration',
          namespace: 'platform',
        },
        data: {
          'load-balance': 'ip_hash',
          'use-http2': 'true',
          'server-tokens': 'false',
          'max-worker-connections': '4096',
          'client-body-timeout': '8',
          'client-header-timeout': '8',
          'keep-alive': '5',
          'limit-conn-zone-variable': 'binary_remote_addr',
        },
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'ClusterRole',
        metadata: {
          name: 'nginx-ingress-clusterrole',
        },
        rules: [
          {
            apiGroups: [
              '',
            ],
            resources: [
              'configmaps',
              'endpoints',
              'nodes',
              'pods',
              'secrets',
            ],
            verbs: [
              'list',
              'watch',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'nodes',
            ],
            verbs: [
              'get',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'services',
            ],
            verbs: [
              'get',
              'list',
              'watch',
            ],
          },
          {
            apiGroups: [
              'extensions',
            ],
            resources: [
              'ingresses',
            ],
            verbs: [
              'get',
              'list',
              'watch',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'events',
            ],
            verbs: [
              'create',
              'patch',
            ],
          },
          {
            apiGroups: [
              'extensions',
            ],
            resources: [
              'ingresses/status',
            ],
            verbs: [
              'update',
            ],
          },
        ],
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'ClusterRoleBinding',
        metadata: {
          name: 'nginx-ingress-clusterrole-nisa-binding',
        },
        roleRef: {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'ClusterRole',
          name: 'nginx-ingress-clusterrole',
        },
        subjects: [
          {
            kind: 'ServiceAccount',
            name: 'nginx-ingress-serviceaccount',
            namespace: 'platform',
          },
        ],
      },
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'Deployment',
        metadata: {
          labels: {
            app: 'ingress-nginx',
          },
          name: 'nginx-ingress-controller',
          namespace: 'platform',
        },
        spec: {
          replicas: 2,
          selector: {
            matchLabels: {
              app: 'ingress-nginx',
            },
          },
          strategy: {
            rollingUpdate: {
              maxSurge: 1,
              maxUnavailable: 1,
            },
            type: 'RollingUpdate',
          },
          template: {
            metadata: {
              annotations: {
                'prometheus.io/port': '10254',
                'prometheus.io/scrape': 'true',
              },
              labels: {
                app: 'ingress-nginx',
              },
            },
            spec: {
              containers: [
                {
                  args: [
                    '/nginx-ingress-controller',
                    '--default-ssl-certificate=$(POD_NAMESPACE)/ingress-elasticio-cert',
                    '--configmap=$(POD_NAMESPACE)/nginx-configuration',
                    '--tcp-services-configmap=$(POD_NAMESPACE)/tcp-services',
                    '--udp-services-configmap=$(POD_NAMESPACE)/udp-services',
                    '--annotations-prefix=nginx.ingress.kubernetes.io',
                  ],
                  env: [
                    {
                      name: 'POD_NAME',
                      valueFrom: {
                        fieldRef: {
                          apiVersion: 'v1',
                          fieldPath: 'metadata.name',
                        },
                      },
                    },
                    {
                      name: 'POD_NAMESPACE',
                      valueFrom: {
                        fieldRef: {
                          apiVersion: 'v1',
                          fieldPath: 'metadata.namespace',
                        },
                      },
                    },
                  ],
                  image: 'quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.20.0',
                  imagePullPolicy: 'IfNotPresent',
                  name: 'nginx-ingress-controller',
                  ports: [
                    {
                      containerPort: 80,
                      name: 'http',
                      protocol: 'TCP',
                    },
                    {
                      containerPort: 443,
                      name: 'https',
                      protocol: 'TCP',
                    },
                  ],
                  resources: {},
                  terminationMessagePath: '/dev/termination-log',
                  terminationMessagePolicy: 'File',
                },
              ],
              serviceAccount: 'nginx-ingress-serviceaccount',
              serviceAccountName: 'nginx-ingress-serviceaccount',
              nodeSelector: {
                'elasticio-role': 'platform',
              },
            },
          },
        },
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'Role',
        metadata: {
          name: 'nginx-ingress-role',
          namespace: 'platform',
        },
        rules: [
          {
            apiGroups: [
              '',
            ],
            resources: [
              'configmaps',
              'pods',
              'secrets',
              'namespaces',
            ],
            verbs: [
              'get',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resourceNames: [
              'ingress-controller-leader-nginx',
            ],
            resources: [
              'configmaps',
            ],
            verbs: [
              'get',
              'update',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'configmaps',
            ],
            verbs: [
              'create',
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'endpoints',
            ],
            verbs: [
              'get',
            ],
          },
        ],
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'RoleBinding',
        metadata: {
          name: 'nginx-ingress-rolebinding',
          namespace: 'platform',
        },
        roleRef: {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'Role',
          name: 'nginx-ingress-role',
        },
        subjects: [
          {
            kind: 'ServiceAccount',
            name: 'nginx-ingress-serviceaccount',
            namespace: 'platform',
          },
        ],
      },
      {
        apiVersion: 'v1',
        kind: 'ServiceAccount',
        metadata: {
          name: 'nginx-ingress-serviceaccount',
          namespace: 'platform',
        },
      },
      {
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: 'tcp-services',
          namespace: 'platform',
        },
        data: {
          '22': 'platform/gitreceiver-service:4022',
        },
      },
      {
        apiVersion: 'v1',
        kind: 'ConfigMap',
        metadata: {
          name: 'udp-services',
          namespace: 'platform',
        },
      },
    ],
    ingress(ingressNameDefault, ingressNameApiDocs, loadBalancerIP, appDomain, apiDomain, webhooksDomain, sshPort, certName, limitConnections):: [
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          labels: {
            app: 'ingress-loadbalancer',
          },
          name: 'ingress-loadbalancer',
          namespace: 'platform',
        },
        spec: {
          type: 'LoadBalancer',
          externalTrafficPolicy: 'Local',
          loadBalancerIP: loadBalancerIP,
          selector: {
            app: 'ingress-nginx',
          },
          ports: [
            {
              name: 'http',
              port: 80,
              protocol: 'TCP',
              targetPort: 80,
            },
            {
              name: 'https',
              port: 443,
              protocol: 'TCP',
              targetPort: 443,
            },
            {
              name: 'ssh',
              port: sshPort,
              protocol: 'TCP',
              targetPort: 22,
            },
          ],
        },
      },
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: ingressNameDefault,
          namespace: 'platform',
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/affinity': 'cookie',
            'nginx.ingress.kubernetes.io/proxy-body-size': '10m'
          } + if limitConnections > 0 then { 'nginx.ingress.kubernetes.io/limit-connections': std.toString(limitConnections) } else {},
        },
        spec: {
          tls: [
            {
              secretName: certName,
              hosts: [
                appDomain,
                apiDomain,
                webhooksDomain,
              ],
            },
          ],
          rules: [
            {
              host: apiDomain,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'api-service',
                      servicePort: 9000,
                    },
                  },
                ],
              },
            },
            {
              host: appDomain,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'frontend-service',
                      servicePort: 8000,
                    },
                  },
                ],
              },
            },
            {
              host: webhooksDomain,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'webhooks-service',
                      servicePort: 5000,
                    },
                  },
                ],
              },
            },
          ],
        },
      },
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: ingressNameApiDocs,
          namespace: 'platform',
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/rewrite-target': '/',
            'nginx.ingress.kubernetes.io/proxy-redirect-from': '/',
            'nginx.ingress.kubernetes.io/proxy-redirect-to': '/docs/',
            'nginx.ingress.kubernetes.io/limit-connections': '200',
            'nginx.ingress.kubernetes.io/proxy-body-size': '1k',
          },
        },
        spec: {
          rules: [
            {
              host: apiDomain,
              http: {
                paths: [
                  {
                    path: '/docs/',
                    backend: {
                      serviceName: 'api-docs-service',
                      servicePort: 8000,
                    },
                  },
                ],
              },
            },
          ],
        },
      },
    ],
    lookout(replicas):: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'lookout',
        namespace: 'platform',
        labels: {
          app: 'lookout',
        },
      },
      spec: {
        replicas: replicas,
        selector: {
          matchLabels: {
            app: 'lookout',
          },
        },
        template: {
          metadata: {
            name: 'lookout',
            labels: {
              app: 'lookout',
            },
          },
          spec: {
            containers: [
              {
                name: 'lookout',
                image: 'elasticio/lookout:' + version,
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
                    value: 'lookout',
                  },
                  {
                    name: 'LOG_LEVEL',
                    value: 'trace',
                  },
                ],
                livenessProbe: {
                  httpGet: {
                    port: 10000,
                    path: '/healthcheck',
                  },
                  initialDelaySeconds: 60,
                  periodSeconds: 10,
                  failureThreshold: 5,
                  successThreshold: 1,
                  timeoutSeconds: 5,
                },
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
    raven(replicas):: [
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
              labels: {
                app: 'raven',
              },
            },
            spec: {
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
          externalTrafficPolicy: 'Cluster',
          ports: [
            {
              name: '8070',
              port: 8070,
              protocol: 'TCP',
              targetPort: 3000,
            },
          ],
          selector: {
            app: 'raven',
          },
          sessionAffinity: 'None',
          type: 'NodePort',
        },
      },
    ],
    scheduler():: {
      kind: 'Deployment',
      apiVersion: 'apps/v1',
      metadata: {
        name: 'scheduler',
        namespace: 'platform',
        labels: {
          app: 'scheduler',
        },
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
    },
    steward(replicas):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'steward',
          namespace: 'platform',
          labels: {
            app: 'steward',
          },
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'steward',
            },
          },
          template: {
            metadata: {
              name: 'steward',
              labels: {
                app: 'steward',
              },
            },
            spec: {
              containers: [
                {
                  name: 'steward',
                  image: 'elasticio/steward:' + version,
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
                      value: 'steward',
                    },
                    {
                      name: 'PORT',
                      value: '3000',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                    {
                      name: 'BASE_URL',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'EXTERNAL_STEWARD_URI',
                        },
                      },
                    },
                    {
                      name: 'STORAGE_URL',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'STEWARD_STORAGE_URI',
                        },
                      },
                    },
                    {
                      name: 'STORAGE_URL_1',
                      valueFrom: {
                        secretKeyRef: {
                          name: 'elasticio',
                          key: 'STEWARD_STORAGE_URI_1',
                          optional: true,
                        },
                      },
                    },
                  ],
                  livenessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 3,
                    httpGet: {
                      port: 3000,
                      path: '/',
                    },
                  },
                  resources: {
                    limits: {
                      memory: '512Mi',
                      cpu: 0.5,
                    },
                    requests: {
                      memory: '256Mi',
                      cpu: 0.2,
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
            app: 'steward-service',
          },
          name: 'steward-service',
          namespace: 'platform',
        },
        spec: {
          externalTrafficPolicy: 'Cluster',
          ports: [
            {
              name: '8200',
              port: 8200,
              protocol: 'TCP',
              targetPort: 3000,
            },
          ],
          selector: {
            app: 'steward',
          },
          sessionAffinity: 'None',
          type: 'NodePort',
        },
        status: {
          loadBalancer: {},
        },
      },
    ],
    webhooks(replicas):: [
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'webhooks',
          namespace: 'platform',
          labels: {
            app: 'webhooks',
          },
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
            spec: {
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
          labels: {
            app: 'webhooks-service',
          },
          name: 'webhooks-service',
          namespace: 'platform',
        },
        spec: {
          externalTrafficPolicy: 'Cluster',
          ports: [
            {
              name: '5000',
              port: 5000,
              protocol: 'TCP',
              targetPort: 5000,
            },
          ],
          selector: {
            app: 'webhooks',
          },
          sessionAffinity: 'None',
          type: 'NodePort',
        },
        status: {
          loadBalancer: {},
        },
      },
    ],
    wiper():: [
      {
        apiVersion: 'batch/v1beta1',
        kind: 'CronJob',
        metadata: {
          name: 'clear-old-debug-tasks',
          namespace: 'platform',
          labels: {
            app: 'wiper',
            subapp: 'clear-old-debug-tasks',
          },
        },
        spec: {
          schedule: '* * * * *',
          concurrencyPolicy: 'Forbid',
          failedJobsHistoryLimit: 1,
          jobTemplate: {
            metadata: {
              creationTimestamp: null,
              labels: {
                app: 'wiper',
                subapp: 'clear-old-debug-tasks',
              },
            },
            spec: {
              template: {
                metadata: {
                  labels: {
                    app: 'wiper',
                    subapp: 'clear-old-debug-tasks',
                  },
                },
                spec: {
                  containers: [
                    {
                      name: 'clear-old-debug-tasks',
                      image: 'elasticio/wiper:' + version,
                      imagePullPolicy: 'IfNotPresent',
                      args: [
                        'node',
                        '/app/index.js',
                        'clear-old-debug-tasks',
                      ],
                      env: [
                        {
                          name: 'APP_NAME',
                          value: 'wiper:clear-old-debug-tasks',
                        },
                        {
                          name: 'ELASTICIO_API_URI',
                          valueFrom: {
                            secretKeyRef: {
                              key: 'API_URI',
                              name: 'elasticio',
                            },
                          },
                        },
                      ],
                      envFrom: [
                        {
                          secretRef: {
                            name: 'elasticio',
                          },
                        },
                      ],
                    },
                  ],
                  imagePullSecrets: [
                    {
                      name: 'elasticiodevops',
                    },
                  ],
                  restartPolicy: 'OnFailure',
                  nodeSelector: {
                    'elasticio-role': 'platform',
                  },
                },
              },
            },
          },
          successfulJobsHistoryLimit: 3,
          suspend: false,
        },
        status: {},
      },
      {
        apiVersion: 'batch/v1beta1',
        kind: 'CronJob',
        metadata: {
          name: 'suspend-tasks-with-failing-containers',
          namespace: 'platform',
          labels: {
            app: 'wiper',
            subapp: 'suspend-tasks-with-failing-containers',
          },
        },
        spec: {
          schedule: '* * * * *',
          concurrencyPolicy: 'Forbid',
          failedJobsHistoryLimit: 1,
          jobTemplate: {
            metadata: {
              creationTimestamp: null,
              labels: {
                app: 'wiper',
                subapp: 'suspend-tasks-with-failing-containers',
              },

            },
            spec: {
              template: {
                metadata: {
                  labels: {
                    app: 'wiper',
                    subapp: 'suspend-tasks-with-failing-containers',
                  },
                },
                spec: {
                  containers: [
                    {
                      name: 'suspend-tasks-with-failing-containers',
                      image: 'elasticio/wiper:' + version,
                      imagePullPolicy: 'IfNotPresent',
                      args: [
                        'node',
                        '/app/index.js',
                        'suspend-tasks-with-failing-containers',
                      ],
                      env: [
                        {
                          name: 'APP_NAME',
                          value: 'wiper:suspend-tasks-with-failing-containers',
                        },
                        {
                          name: 'ELASTICIO_API_URI',
                          valueFrom: {
                            secretKeyRef: {
                              key: 'API_URI',
                              name: 'elasticio',
                            },
                          },
                        },
                      ],
                      envFrom: [
                        {
                          secretRef: {
                            name: 'elasticio',
                          },
                        },
                      ],
                    },
                  ],
                  imagePullSecrets: [
                    {
                      name: 'elasticiodevops',
                    },
                  ],
                  restartPolicy: 'OnFailure',
                  nodeSelector: {
                    'elasticio-role': 'platform',
                  },
                },
              },
            },
          },
          successfulJobsHistoryLimit: 3,
          suspend: false,
        },
        status: {},
      },
      {
        apiVersion: 'batch/v1beta1',
        kind: 'CronJob',
        metadata: {
          name: 'watch-and-finish-contract-delete',
          namespace: 'platform',
          labels: {
            app: 'wiper',
            subapp: 'watch-and-finish-contract-delete',
          },
        },
        spec: {
          schedule: '*/3 * * * *',
          concurrencyPolicy: 'Forbid',
          failedJobsHistoryLimit: 1,
          jobTemplate: {
            metadata: {
              creationTimestamp: null,
              labels: {
                app: 'wiper',
                subapp: 'watch-and-finish-contract-delete',
              },
            },
            spec: {
              template: {
                metadata: {
                  labels: {
                    app: 'wiper',
                    subapp: 'watch-and-finish-contract-delete',
                  },
                },
                spec: {
                  containers: [
                    {
                      name: 'watch-and-finish-contract-delete',
                      image: 'elasticio/wiper:' + version,
                      imagePullPolicy: 'IfNotPresent',
                      args: [
                        'node',
                        '/app/index.js',
                        'watch-and-finish-contract-delete',
                      ],
                      env: [
                        {
                          name: 'APP_NAME',
                          value: 'wiper:watch-and-finish-contract-delete',
                        },
                        {
                          name: 'ELASTICIO_API_URI',
                          valueFrom: {
                            secretKeyRef: {
                              key: 'API_URI',
                              name: 'elasticio',
                            },
                          },
                        },
                      ],
                      envFrom: [
                        {
                          secretRef: {
                            name: 'elasticio',
                          },
                        },
                      ],
                    },
                  ],
                  imagePullSecrets: [
                    {
                      name: 'elasticiodevops',
                    },
                  ],
                  restartPolicy: 'OnFailure',
                  nodeSelector: {
                    'elasticio-role': 'platform',
                  },
                },
              },
            },
          },
          successfulJobsHistoryLimit: 3,
          suspend: false,
        },
        status: {},
      },
      {
        apiVersion: 'batch/v1beta1',
        kind: 'CronJob',
        metadata: {
          name: 'watch-queues-overflow',
          namespace: 'platform',
          labels: {
            app: 'wiper',
            subapp: 'watch-queues-overflow',
          },
        },
        spec: {
          schedule: '* * * * *',
          concurrencyPolicy: 'Forbid',
          failedJobsHistoryLimit: 1,
          jobTemplate: {
            metadata: {
              creationTimestamp: null,
              labels: {
                app: 'wiper',
                subapp: 'watch-queues-overflow',
              },
            },
            spec: {
              template: {
                metadata: {
                  labels: {
                    app: 'wiper',
                    subapp: 'watch-queues-overflow',
                  },
                },
                spec: {
                  containers: [
                    {
                      name: 'watch-queues-overflow',
                      image: 'elasticio/wiper:' + version,
                      imagePullPolicy: 'IfNotPresent',
                      args: [
                        'node',
                        '/app/index.js',
                        'watch-queues-overflow',
                      ],
                      env: [
                        {
                          name: 'APP_NAME',
                          value: 'wiper:watch-queues-overflow',
                        },
                        {
                          name: 'ELASTICIO_API_URI',
                          valueFrom: {
                            secretKeyRef: {
                              key: 'API_URI',
                              name: 'elasticio',
                            },
                          },
                        },
                      ],
                      envFrom: [
                        {
                          secretRef: {
                            name: 'elasticio',
                          },
                        },
                      ],
                    },
                  ],
                  imagePullSecrets: [
                    {
                      name: 'elasticiodevops',
                    },
                  ],
                  restartPolicy: 'OnFailure',
                  nodeSelector: {
                    'elasticio-role': 'platform',
                  },
                },
              },
            },
          },
          successfulJobsHistoryLimit: 3,
          suspend: false,
        },
        status: {},
      },
      {
        apiVersion: 'batch/v1beta1',
        kind: 'CronJob',
        metadata: {
          name: 'suspend-contracts',
          namespace: 'platform',
          labels: {
            app: 'wiper',
            subapp: 'suspend-contracts',
          },
        },
        spec: {
          schedule: '* * * * *',
          concurrencyPolicy: 'Forbid',
          failedJobsHistoryLimit: 1,
          jobTemplate: {
            metadata: {
              creationTimestamp: null,
              labels: {
                app: 'wiper',
                subapp: 'suspend-contracts',
              },
            },
            spec: {
              template: {
                metadata: {
                  labels: {
                    app: 'wiper',
                    subapp: 'suspend-contracts',
                  },
                },
                spec: {
                  containers: [
                    {
                      name: 'suspend-contracts',
                      image: 'elasticio/wiper:' + version,
                      imagePullPolicy: 'IfNotPresent',
                      args: [
                        'node',
                        '/app/index.js',
                        'suspend-contracts',
                      ],
                      env: [
                        {
                          name: 'APP_NAME',
                          value: 'wiper:suspend-contracts',
                        },
                        {
                          name: 'ELASTICIO_API_URI',
                          valueFrom: {
                            secretKeyRef: {
                              key: 'API_URI',
                              name: 'elasticio',
                            },
                          },
                        },
                      ],
                      envFrom: [
                        {
                          secretRef: {
                            name: 'elasticio',
                          },
                        },
                      ],
                    },
                  ],
                  imagePullSecrets: [
                    {
                      name: 'elasticiodevops',
                    },
                  ],
                  restartPolicy: 'OnFailure',
                  nodeSelector: {
                    'elasticio-role': 'platform',
                  },
                },
              },
            },
          },
          successfulJobsHistoryLimit: 3,
          suspend: false,
        },
        status: {},
      },
    ],
    storageSlugsPVNfs(pvName, server, path, storage = '1Ti', pvGid = 1502):: [{
      kind: 'PersistentVolume',
      apiVersion: 'v1',
      metadata: {
        name: pvName,
        namespace: 'platform',
        annotations: {
          'pv.beta.kubernetes.io/gid': std.toString(pvGid),
        },
      },
      spec: {
        storageClassName: 'platform-storage-slugs',
        capacity: {
          storage: storage,
        },
        accessModes: [
          'ReadWriteMany',
        ],
        nfs: {
          path: path,
          server: server,
        },
      },
    }],
    storageSlugsPVAzure(pvName, accountName, accountKey, shareName, storage = '1Ti', pvGid = 1502):: [
      {
        apiVersion: 'v1',
        data: {
            azurestorageaccountkey: std.base64(accountKey),
            azurestorageaccountname: std.base64(accountName)
        },
        kind: 'Secret',
        metadata: {
            name: 'azure-storage-secret',
            namespace: 'platform',
        },
        type: 'Opaque'
      },
      {
        kind: 'PersistentVolume',
        apiVersion: 'v1',
        metadata: {
          name: pvName,
          namespace: 'platform',
          annotations: {
            'pv.beta.kubernetes.io/gid': std.toString(pvGid),
          },
        },
        spec: {
          storageClassName: 'platform-storage-slugs',
          capacity: {
            storage: storage,
          },
          accessModes: [
            'ReadWriteMany',
          ],
          azureFile: {
              secretName: 'azure-storage-secret',
              secretNamespace: null,
              shareName: shareName
          },
          mountOptions: [
              'dir_mode=0775',
              'file_mode=0775',
              'gid=' + pvGid
          ]
        }
      }
    ],
    storageSlugs(replicas, lbIp, storage = '1Ti', slugsSubPath = 'slugs', stewardSubPath = 'steward'):: [
      {
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
          name: 'platform-storage-slugs',
          namespace: 'platform',
          labels: {
            app: 'platform-storage-slugs',
          },
        },
        spec: {
          replicas: replicas,
          selector: {
            matchLabels: {
              app: 'platform-storage-slugs',
            },
          },
          template: {
            metadata: {
              name: 'platform-storage-slugs',
              labels: {
                app: 'platform-storage-slugs',
              },
            },
            spec: {
              containers: [
                {
                  name: 'platform-storage-slugs',
                  image: 'elasticio/platform-storage-slugs:' + version,
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
                      value: 'platform-storage-slugs',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                  ],
                  livenessProbe: {
                    initialDelaySeconds: 10,
                    periodSeconds: 20,
                    tcpSocket: {
                      port: 8000,
                    },
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
                  volumeMounts: [
                    {
                      mountPath: '/home/nginx/data/www/slugs',
                      name: 'platform-storage-slugs-storage',
                      subPath: slugsSubPath,
                    },
                    {
                      mountPath: '/home/nginx/data/www/steward',
                      name: 'platform-storage-slugs-storage',
                      subPath: stewardSubPath,
                    },
                  ],
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
              volumes: [
                {
                  name: 'platform-storage-slugs-storage',
                  persistentVolumeClaim: {
                    claimName: 'platform-storage-slugs-volume-claim',
                  },
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
            app: 'platform-storage-slugs-service',
          },
          name: 'platform-storage-slugs-service',
          namespace: 'platform',
        },
        spec: {
          type: 'NodePort',
          selector: {
            app: 'platform-storage-slugs',
          },
          ports: [
            {
              name: '9999',
              port: 9999,
              protocol: 'TCP',
              targetPort: 8000,
            },
          ],
        },
      },
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          labels: {
            app: 'platform-storage-slugs-loadbalancer',
          },
          annotations: {
            'cloud.google.com/load-balancer-type': 'Internal',
          },
          name: 'platform-storage-slugs-loadbalancer',
          namespace: 'platform',
        },
        spec: {
          type: 'LoadBalancer',
          loadBalancerIP: lbIp,
          selector: {
            app: 'platform-storage-slugs',
          },
          ports: [
            {
              name: '9999',
              port: 9999,
              protocol: 'TCP',
              targetPort: 8000,
            },
          ],
        }
      },
      {
        kind: 'PersistentVolumeClaim',
        apiVersion: 'v1',
        metadata: {
          name: 'platform-storage-slugs-volume-claim',
          namespace: 'platform',
        },
        spec: {
          storageClassName: 'platform-storage-slugs',
          accessModes: [
            'ReadWriteMany',
          ],
          resources: {
            requests: {
              storage: storage,
            },
          },
        },
      },
    ]
  },
  gendry():: {
    apiVersion: 'batch/v1',
    kind: 'Job',
    metadata: {
      name: 'gendry',
      namespace: 'platform',
      labels: {
        app: 'gendry',
      },
    },
    spec: {
      backoffLimit: 0,
      template: {
        metadata: {
          name: 'gendry',
          labels: {
            app: 'gendry',
          },
        },
        spec: {
          restartPolicy: 'Never',
          containers: [
            {
              name: 'gendry',
              image: 'elasticio/gendry:' + version,
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
                  value: 'gendry',
                },
                {
                  name: 'LOG_LEVEL',
                  value: 'trace',
                },
                {
                  name: 'EMAIL',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'elasticio',
                      key: 'TENANT_ADMIN_EMAIL',
                    },
                  },
                },
                {
                  name: 'PASSWORD',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'elasticio',
                      key: 'TENANT_ADMIN_PASSWORD',
                    },
                  },
                },
              ],
              imagePullPolicy: 'Always',
            },
          ],
          imagePullSecrets: [
            {
              name: 'elasticiodevops',
            },
          ],
          nodeSelector: {
            'elasticio-role': 'platform',
          },
        },
      },
    },
  }
}
