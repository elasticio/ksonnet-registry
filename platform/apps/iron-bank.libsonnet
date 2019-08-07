local version = import 'elasticio/platform/version.json';

{
  app()::[
    {
      apiVersion: 'apps/v1',
      kind: 'DaemonSet',
      metadata: {
        annotations: {
          // Copied from
          // https://github.com/google/cadvisor/blob/83240cc997e91ec38fb853c07ff318491bd354cb/deploy/kubernetes/base/daemonset.yaml
          'seccomp.security.alpha.kubernetes.io/pod': 'docker/default',
        },
        labels: {
          app: 'cadvisor',
        },
        name: 'cadvisor',
        namespace: 'platform',
      },
      spec: {
        selector: {
          matchLabels: {
            app: 'cadvisor',
          }
        },
        template: {
          metadata: {
            labels: {
              app: 'cadvisor',
            }
          },
          spec: {
            containers: [
              {
                args: [
                  '--housekeeping_interval=2s',
                  '--storage_duration=10s',
                  '--application_metrics_count_limit=2',
                  '--disable_metrics=tcp,udp,disk,network,process,sched',
                  '--docker_only',
                ],
                image: 'k8s.gcr.io/cadvisor:v0.33.0',
                name: 'cadvisor',
                ports: [
                  {
                    containerPort: 8080,
                    name: 'http',
                    protocol: 'TCP',
                  },
                ],
                resources: {
                  limits: {
                    cpu: '300m',
                    memory: '2000Mi',
                  },
                  requests: {
                    cpu: '150m',
                    memory: '200Mi',
                  },
                },
                volumeMounts: [
                  {
                    mountPath: '/rootfs',
                    name: 'rootfs',
                    readOnly: true,
                  },
                  {
                    mountPath: '/var/run',
                    name: 'var-run',
                    readOnly: true,
                  },
                  {
                    mountPath: '/sys',
                    name: 'sys',
                    readOnly: true,
                  },
                  {
                    mountPath: '/var/lib/docker',
                    name: 'docker',
                    readOnly: true,
                  },
                  {
                    mountPath: '/dev/disk',
                    name: 'disk',
                    readOnly: true,
                  },
                ]
              }
            ],
            automountServiceAccountToken: false,
            terminationGracePeriodSeconds: 30,
            volumes: [
              {
                hostPath: {
                  path: '/',
                },
                name: 'rootfs',
              },
              {
                hostPath: {
                  path: '/var/run',
                },
                name: 'var-run',
              },
              {
                hostPath: {
                  path: '/sys',
                },
                name: 'sys',
              },
              {
                hostPath: {
                  path: '/var/lib/docker',
                },
                name: 'docker',
              },
              {
                hostPath: {
                  path: '/dev/disk',
                },
                name: 'disk',
              },
            ],
          },
        },
      },
    },
    {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: {
        name: 'iron-bank-account',
        namespace: 'platform',
      },
    },
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'ClusterRole',
      metadata: {
        name: 'iron-bank-role',
      },
      rules: [
        {
          apiGroups: [''],
          resources: ['pods'],
          verbs: ['get', 'list', 'watch'],
        }
      ],
    },
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'ClusterRoleBinding',
      metadata: {
        name: 'iron-bank-rolebinding',
      },
      roleRef: {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'ClusterRole',
        name: 'iron-bank-role',
      },
      subjects: [
        {
          kind: 'ServiceAccount',
          name: 'iron-bank-account',
          namespace: 'platform',
        },
      ],
    },
    {
      kind: 'Deployment',
      apiVersion: 'apps/v1',
      metadata: {
        name: 'iron-bank',
        namespace: 'platform',
        labels: {
          app: 'iron-bank',
        },
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: 'iron-bank',
          },
        },
        template: {
          metadata: {
            name: 'iron-bank',
            labels: {
              app: 'iron-bank',
            },
          },
          spec: {
            containers: [
              {
                name: 'iron-bank',
                image: 'elasticio/iron-bank:' + version,
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
                    value: 'iron-bank',
                  },
                  {
                    name: 'PORT',
                    value: '3000',
                  },
                  {
                    name: 'LOG_LEVEL',
                    value: 'info',
                  },
                  {
                    name: 'CLICKHOUSE_URI',
                    valueFrom: {
                      secretKeyRef: {
                        name: 'elasticio',
                        key: 'IRON_BANK_CLICKHOUSE_URI',
                      },
                    },
                  },
                ],
                livenessProbe: {
                  httpGet: {
                    port: 3000,
                    path: '/healthcheck',
                  },
                  initialDelaySeconds: 10,
                  periodSeconds: 3,
                  failureThreshold: 3,
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
                imagePullPolicy: 'IfNotPresent',
              },
            ],
            imagePullSecrets: [
              {
                name: 'elasticiodevops',
              },
            ],
            serviceAccountName: 'iron-bank-account',
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
          app: 'iron-bank-service',
        },
        name: 'iron-bank-service',
        namespace: 'platform',
      },
      spec: {
        selector: {
          app: 'iron-bank',
        },
        ports: [
          {
            name: '3000',
            port: 3000,
            protocol: 'TCP',
          },
        ],
      },
    },
  ]
}