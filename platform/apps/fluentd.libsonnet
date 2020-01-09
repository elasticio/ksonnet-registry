{
  app(execGelfProto, execGelfHost, execGelfPort):: [
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
                  image: 'elasticio/fluentd-kubernetes-gelf:8e5ffb6e02d087789ebaae09c9738a1f1c481c9a',
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
    ]
}
