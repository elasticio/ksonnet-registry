local version = import 'elasticio/platform/version.json';

{
  app(secretName, version)::[
      {
        kind: 'Deployment',
        apiVersion: 'apps/v1',
        metadata: {
          name: 'handmaiden',
          namespace: 'platform',
          labels: {
            app: 'handmaiden',
          },
        },
        spec: {
          replicas: 1,
          selector: {
            matchLabels: {
              app: 'handmaiden',
            },
          },
          template: {
            metadata: {
              name: 'handmaiden',
              labels: {
                app: 'handmaiden',
              },
            },
            spec: {
              containers: [
                {
                  name: 'handmaiden',
                  image: 'elasticio/handmaiden:' + version,
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
                      value: 'handmaiden',
                    },
                    {
                      name: 'API_URI',
                      value: 'http://api-service.platform.svc.cluster.local:9000',
                    },
                    {
                      name: 'PORT',
                      value: '12000',
                    },
                    {
                      name: 'LOG_LEVEL',
                      value: 'trace',
                    },
                    {
                      name: 'API_SERVICE',
                      value: 'api-service/9000'
                    },
                    {
                      name: 'FRONTEND_SERVICE',
                      value: 'frontend-service/8000'
                    },
                    {
                      name: 'WEBHOOKS_SERVICE',
                      value: 'webhooks-service/5000'
                    },
                    {
                      name: 'APIDOCS_SERVICE',
                      value: 'api-docs-service/8000'
                    },
                    {
                      name: 'DEFAULT_CERT_SECRET_NAME',
                      value: secretName
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
              serviceAccountName: 'handmaiden-account',
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
          name: 'handmaiden-account',
          namespace: 'platform',
          labels: {
            app: 'handmaiden',
          }
        },
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'Role',
        metadata: {
          name: 'handmaiden-role',
          namespace: 'platform',
          labels: {
            app: 'handmaiden',
          }
        },
        rules: [
          {
            apiGroups: [
              'extensions'
            ],
            resources: [
              'ingresses'
            ],
            verbs: [
              'create',
              'delete',
              'get',
              'list',
              'patch',
              'update'
            ],
          },
          {
            apiGroups: [
              '',
            ],
            resources: [
              'secrets',
            ],
            verbs: [
              'create',
              'delete',
              'get',
              'list',
              'patch',
              'update'
            ],
          },
        ],
      },
      {
        apiVersion: 'rbac.authorization.k8s.io/v1',
        kind: 'RoleBinding',
        metadata: {
          name: 'handmaiden-rolebinding',
          namespace: 'platform',
          labels: {
            app: 'handmaiden',
          }
        },
        roleRef: {
          apiGroup: 'rbac.authorization.k8s.io',
          kind: 'Role',
          name: 'handmaiden-role',
        },
        subjects: [
          {
            kind: 'ServiceAccount',
            name: 'handmaiden-account',
            namespace: 'platform',
          },
        ],
      },
    ]
}
