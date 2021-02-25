local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';

{
  conf():: [
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
          'use-http2': 'true',
          'server-tokens': 'false',
          'max-worker-connections': '4096',
          'client-body-timeout': '8',
          'client-header-timeout': '8',
          // TODO: so large value is for webhooks endpoint, make webhooks a separate Ingress and use 'proxy-body-size'
          // for it https://github.com/elasticio/elasticio/issues/2957
          'proxy-body-size': '1g',
          'keep-alive': '5',
          'proxy-protocol-header-timeout': '180s',
          'proxy-read-timeout': '180',
          'limit-conn-zone-variable': 'binary_remote_addr',
          // Give some time to finish git push into gitreceiver
          // https://github.com/elasticio/platform/issues/912
          'worker-shutdown-timeout': '5m',
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
              'networking.k8s.io',
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
              'networking.k8s.io',
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
        apiVersion: 'apps/v1',
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
              labels: {
                app: 'ingress-nginx',
              },
            },
            spec: podAffinitySpreadNodes.call('ingress-nginx') + {
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
                  image: 'k8s.gcr.io/ingress-nginx/controller:v0.44.0',
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
    ]
}
