local version = import 'elasticio/platform/version.json';

{
  app(name):: {
      apiVersion: 'batch/v1',
      kind: 'Job',
      metadata: {
        name: 'gendry',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'gendry',
          'app.kubernetes.io/managed-by': 'Helm'
        }
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
                  {
                    name: 'SERVICE_ACCOUNTS',
                    valueFrom: {
                      secretKeyRef: {
                        name: 'elasticio',
                        key: 'GENDRY_SERVICE_ACCOUNTS',
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
