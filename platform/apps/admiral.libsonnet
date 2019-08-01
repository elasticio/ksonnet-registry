local version = import 'elasticio/platform/version.json';

{
  app():: [
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
              annotations: {
                "prometheus.io/scrape": "true",
                "prometheus.io/port": "12000"
              }
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
                    }
                  ],
                  ports: [{
                    containerPort: 12000
                  }],
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
              affinity: {
                nodeAffinity: {
                  requiredDuringSchedulingIgnoredDuringExecution: {
                    nodeSelectorTerms: [
                      {
                        matchExpressions: [
                          {
                            key: 'elasticio-role',
                            operator: 'NotIn',
                            values: [
                              'tasks',
                              'monitoring',
                            ],
                          },
                        ],
                      },
                    ],
                  },
                  preferredDuringSchedulingIgnoredDuringExecution: [
                    {
                      weight: 1,
                      preference: {
                        matchExpressions: [
                          {
                            key: 'eio-app',
                            operator: 'In',
                            values: [
                              'admiral',
                            ],
                          },
                        ],
                      },
                    },
                  ],
                },
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
              'pods',
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
    ]
}
