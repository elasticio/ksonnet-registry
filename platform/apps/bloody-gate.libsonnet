local version = import 'elasticio/platform/version.json';

local k = import 'k.libsonnet';
{
  app(name, ipAddress, caCert, caKey):: [
    {
      kind: 'Deployment',
      apiVersion: 'apps/v1',
      metadata: {
        name: 'bloody-gate',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'bloody-gate',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: 'bloody-gate'
          }
        },
        template: {
          metadata: {
            name: 'bloody-gate',
            labels: {
              app: 'bloody-gate'
            }
          },
          spec: {
            containers: [{
              name: 'bloody-gate',
              image: 'elasticio/bloody-gate:' + version,
              envFrom: [{
                secretRef: {
                  name: 'elasticio'
                }
              }],
              env: [
                {
                  name: 'APP_NAME',
                  value: 'bloody-gate'
                },
                {
                  name: 'PORT',
                  value: '998'
                },
                {
                  name: 'LOG_LEVEL',
                  value: 'debug'
                },
                {
                  name: 'AGENT_MANAGEMENT_API',
                  value: 'http://knight-of-the-bloody-gate-service.platform.svc.cluster.local:3000'
                },
                {
                  name: 'PLATFORM_PODS_NAMESPACE',
                  value: 'platform'
                },
                {
                  name: 'TASKS_PODS_NAMESPACE',
                  value: 'tasks'
                },
                {
                  name: 'SELF_SELECTOR',
                  value: '{"app": "bloody-gate"}'
                }
              ],
              lifecycle: {
                postStart: {
                  exec: {
                    // We need to have net.ipv4.ip_forward=1 inside container.
                    // this sysctl option may be forbidden at installation of k8s
                    // so pod.spec.securityContext.sysctls does not always work
                    // so choice => privileged container + manually set sysctl
                    // sad but true :(
                    command: ['sysctl', 'net.ipv4.ip_forward=1']
                  }
                }
              },
              ports: [{
                containerPort: 998
              }],
              readinessProbe: {
                httpGet: {
                  port: 998,
                  path: '/readiness'
                },
                initialDelaySeconds: 60,
                periodSeconds: 10,
                failureThreshold: 5,
                successThreshold: 1,
                timeoutSeconds: 5
              },
              livenessProbe: {
                httpGet: {
                  port: 998,
                  path: '/healthcheck'
                },
                initialDelaySeconds: 60,
                periodSeconds: 10,
                failureThreshold: 5,
                successThreshold: 1,
                timeoutSeconds: 5
              },
              resources: {
                limits: {
                  memory: '2048Mi',
                  cpu: 2
                },
                requests: {
                  memory: '256Mi',
                  cpu: 0.1
                }
              },
              terminationMessagePath: '/dev/termination-log',
              terminationMessagePolicy: 'File',
              imagePullPolicy: 'Always',
              securityContext: {
                // unfortunatelly have to make container privileged to make it able to set net.ipv4.ip_forward=1
                privileged: true,
                allowPrivilegeEscalation: true,
                capabilities: {
                  add: ['NET_ADMIN', 'NET_RAW', 'MKNOD', 'NET_BIND_SERVICE'],
                  drop: ['all']
                }
              }
            }],
            imagePullSecrets: [{
              name: 'elasticiodevops'
            }],
            serviceAccountName: 'bloody-gate-account',
            restartPolicy: 'Always',
            terminationGracePeriodSeconds: 30,
            nodeSelector: {
              'elasticio-role': 'platform'
            }
          }
        },
        strategy: {
          type: 'RollingUpdate',
          rollingUpdate: {
            maxUnavailable: 1,
            maxSurge: 0
          }
        }
      }
    },
    {
      kind: 'Deployment',
      apiVersion: 'apps/v1',
      metadata: {
        name: 'knight-of-the-bloody-gate',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'knight-of-the-bloody-gate',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        replicas: 1,
        selector: {
          matchLabels: {
            app: 'knight-of-the-bloody-gate'
          }
        },
        template: {
          metadata: {
            name: 'knight-of-the-bloody-gate',
            labels: {
              app: 'knight-of-the-bloody-gate'
            }
          },
          spec: {
            containers: [
              {
                name: 'knight-of-the-bloody-gate',
                image: 'elasticio/knight-of-the-bloody-gate:' + version,
                envFrom: [
                  {
                    secretRef: {
                      name: 'elasticio'
                    }
                  }
                ],
                env: [
                  {
                    name: 'CA_CERTIFICATE',
                    valueFrom: {
                      secretKeyRef: {
                        name: 'knight-of-the-bloody-gate-ca',
                        key: 'tls.crt',
                      }
                    }
                  },
                  {
                    name: 'CA_KEY',
                    valueFrom: {
                      secretKeyRef: {
                        name: 'knight-of-the-bloody-gate-ca',
                        key: 'tls.key',
                      }
                    }
                  },
                  {
                    name: 'REMOTE_ADDRESS',
                    valueFrom: {
                      secretKeyRef: {
                        name: 'elasticio',
                        key: 'AGENT_VPN_ENTRYPOINT',
                      }
                    }
                  },
                  {
                    name: 'APP_NAME',
                    value: 'knight-of-the-bloody-gate'
                  },
                  {
                    name: 'PORT',
                    value: '3000'
                  },
                  {
                    name: 'LOG_LEVEL',
                    value: 'debug'
                  }
                ],
                ports: [{
                  containerPort: 3000
                }],
                livenessProbe: {
                  httpGet: {
                    port: 3000,
                    path: '/healthcheck'
                  },
                  initialDelaySeconds: 60,
                  periodSeconds: 10,
                  failureThreshold: 5,
                  successThreshold: 1,
                  timeoutSeconds: 5
                },
                readinessProbe: {
                  httpGet: {
                    port: 3000,
                    path: '/readiness'
                  },
                  initialDelaySeconds: 60,
                  periodSeconds: 10,
                  failureThreshold: 5,
                  successThreshold: 1,
                  timeoutSeconds: 5
                },
                resources: {
                  limits: {
                    memory: '512Mi',
                    cpu: 1
                  },
                  requests: {
                    memory: '256Mi',
                    cpu: 0.1
                  }
                },
                terminationMessagePath: '/dev/termination-log',
                terminationMessagePolicy: 'File',
                imagePullPolicy: 'Always',
                securityContext: {
                  privileged: false,
                  allowPrivilegeEscalation: false,
                  capabilities: {
                    drop: ['all']
                  }
                }
              }
            ],
            imagePullSecrets: [
              {
                name: 'elasticiodevops'
              }
            ],
            restartPolicy: 'Always',
            terminationGracePeriodSeconds: 30,
            nodeSelector: {
              'elasticio-role': 'platform'
            }
          }
        },
        strategy: {
          type: 'RollingUpdate',
          rollingUpdate: {
            maxUnavailable: 1,
            maxSurge: 0
          }
        }
      }
    },
    {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        name: "knight-of-the-bloody-gate-service",
        namespace: "platform",
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: "knight-of-the-bloody-gate-service",
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        type: "ClusterIP",
        ports: [
          {
            name: "3000",
            port: 3000,
            protocol: "TCP",
            targetPort: 3000
          }
        ],
        selector: {
          app: "knight-of-the-bloody-gate"
        },
        sessionAffinity: "None"
      }
    },
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'bloody-gate-loadbalancer',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'bloody-gate-loadbalancer',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        type: 'LoadBalancer',
        externalTrafficPolicy: 'Local',
        loadBalancerIP: ipAddress,
        selector: {
          app: 'bloody-gate'
        },
        ports: [
          {
            name: 'vpn-entrypoint',
            port: 443,
            protocol: 'TCP',
            targetPort: 443
          }
        ]
      }
    },
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: 'bloody-gate-service',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'bloody-gate-service',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      spec: {
        type: 'ClusterIP',
        clusterIP: 'None',
        selector: {
          app: 'bloody-gate'
        }
      }
    },
    k.core.v1.secret.new(
      name='knight-of-the-bloody-gate-ca',
      data={
        'tls.crt': caCert,
        'tls.key': caKey
      },
      type='kubernetes.io/tls'
    ).withNamespace('platform')
    .withLabels({ 'app.kubernetes.io/managed-by': 'Helm' })
    .withAnnotations({ 'meta.helm.sh/release-name': name,
        'meta.helm.sh/release-namespace': 'default' }),
    {
      apiVersion: 'v1',
      kind: 'ServiceAccount',
      metadata: {
        name: 'bloody-gate-account',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          'app.kubernetes.io/managed-by': 'Helm'
        }
      }
    },
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'Role',
      metadata: {
        name: 'bloody-gate-role',
        namespace: 'platform',
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
            'networking.k8s.io'
          ],
          resources: [
            'networkpolicies'
          ],
          verbs: [
            'create',
            'delete',
            'get',
            'patch',
            'update'
          ]
        }
      ]
    },
    {
      apiVersion: 'rbac.authorization.k8s.io/v1',
      kind: 'RoleBinding',
      metadata: {
        name: 'bloody-gate-rolebinding',
        namespace: 'platform',
        annotations: {
          'meta.helm.sh/release-name': name,
          'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
          app: 'bloody-gate',
          'app.kubernetes.io/managed-by': 'Helm'
        }
      },
      roleRef: {
        apiGroup: 'rbac.authorization.k8s.io',
        kind: 'Role',
        name: 'bloody-gate-role'
      },
      subjects: [{
        kind: 'ServiceAccount',
        name: 'bloody-gate-account',
        namespace: 'platform'
      }]
    }
  ]
}
