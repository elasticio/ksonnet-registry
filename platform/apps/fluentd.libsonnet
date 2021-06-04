local version = import 'elasticio/platform/version.json';

{
  app(name, execGelfProto, execGelfHost, execGelfPort):: [
      {
        apiVersion: 'v1',
        kind: 'ServiceAccount',
        metadata: {
          name: 'eio-fluentd-account',
          namespace: 'platform',
          annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            'app.kubernetes.io/managed-by': 'Helm'
          }
        },
      },
      {
        apiVersion: 'apps/v1',
        kind: 'DaemonSet',
        metadata: {
          name: 'eio-fluentd',
          namespace: 'platform',
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            app: 'eio-fluentd',
            'app.kubernetes.io/managed-by': 'Helm'
          }
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
                std.prune({
                  env: [
                    if std.isString(execGelfProto) then {
                      name: 'GELF_PROTOCOL_EIO_EXEC',
                      value: execGelfProto,
                    },
                    if std.isString(execGelfHost) then {
                      name: 'GELF_HOST_EIO_EXEC',
                      value: execGelfHost,
                    },
                    if std.isString(execGelfPort) then {
                      name: 'GELF_PORT_EIO_EXEC',
                      value: execGelfPort,
                    },
                  ],
                  envFrom: [
                    {
                      secretRef: {
                        name: 'elasticio',
                      },
                    },
                  ],
                  image: 'elasticio/fluentd-kubernetes-gelf:'+ version,
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
                }),
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
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            'app.kubernetes.io/managed-by': 'Helm'
          }
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
          annotations: {
            'meta.helm.sh/release-name': name,
            'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
            'app.kubernetes.io/managed-by': 'Helm'
          }
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
    ]
}
