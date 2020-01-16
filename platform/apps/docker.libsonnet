local k = import 'k.libsonnet';
// Docker registry design
// There is several "strange" solution have been used.
// All of them was implemented to overcome limitations/problems of docker and/or kubernetes.
// Problem #1 NodePort service.
// docker registry is used from two places
// 1. gitreceiver service inside k8s
// 2. dockerd's on kubernetes nodes.
// Naive solution: connect to docker registry as always in k8s by service domain name (e.g. 'docker-service-registry.platform.cluster.svc.local)
// But there is a problem: kuberntes nodes itself does not use kubernetes dns (kubedns/coredns depending on k8s version)
// so dockerd on kubernetes nodes is not able to resolve in-cluster service domain names
// possible options:
// 1. use ip address of service directly. Problems: dangerous. It is not fixed and may change at any deploy
// 2. use loadbalancer service, attach private static ip address to it and use this ip (will work but requires additional efforts)
// 3. use 2 + register this ip in dns (even worse in terms of ops work)
// Finally solution: use NodePort service. It exposes docker registry at fixed port at all nodes. So docker registry will be
// accessible at localhost:port or 127.0.0.1:port at all machines, that gives us stable though installation lifetime "endpoint"
// without additional dependencies

// Sorry have to write this function. Reason: docker registry uri frequently required
// as its parts port/host/user/pass separtely. But I don't want to have 4 parameters
// Localized and hidden complexity is better than complexity at module communication level
local parseUri(uri) = {
  local replaceAtBegin(arg, replacement) = std.substr(
    arg,
    std.length(replacement),
    std.length(arg) - std.length(replacement)
  ),

  local proto = if std.startsWith(uri, 'https://') then 'https://' else
    if std.startsWith(uri, 'http://') then 'http://',

  local parts = std.split(replaceAtBegin(uri, proto), '@'),

  local loginPass = if std.length(parts) == 2 then std.split(parts[0], ':'),
  local domainAndPath = std.splitLimit(if std.length(parts) == 2 then parts[1] else parts[0], '/', 1),
  local hostAndPort = std.split(domainAndPath[0], ':'),
  local path = if std.length(domainAndPath) > 1 then '/' + domainAndPath[1] else '/',

  proto: proto,
  username: if loginPass != null then loginPass[0],
  password: if loginPass != null then loginPass[1],
  host: hostAndPort[0],
  port: if std.length(hostAndPort) > 1 then hostAndPort[1],
  path: path
};

{
  app(dockerRegistryUri, dockerRegistrySecretName, sharedSecret, replicas=2, tasksNamespace='tasks'):: [
    {
      local parsedDockerUri = parseUri(dockerRegistryUri),
      apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          labels: {
            app: 'docker-registry-service'
          },
          name: 'docker-registry-service',
          namespace: 'platform'
        },
        spec: {
          // IMPORTANT!!!! NodePort service should be used here.
          // reason: due to this it's possible to use localhost as docker registry url
          // on all machines.
          // We can not use clusterIp service, because dockerd runs inside node (not inside k8s)
          // and can not resolve in dns  service domain name
          // we can not use clusterIp service ip address, because it can change any moment as k8s wishes
          // so only one working option except NodePort
          // is to use LoadBalancer service type, attach private static ip address to it
          // and use this ip (or dns name attached to this ip) as docker registry URI
          // but that is fucking inconvenient from ops point of view.
          type: 'NodePort',
          ports: [{
            name: '5000',
            port: 5000,
            protocol: 'TCP',
            targetPort: 5000,
            nodePort: std.parseInt(parsedDockerUri.port)
          }],
          selector: {
            app: 'docker-registry'
          },
          sessionAffinity: 'ClientIP'
        }
    },
    k.core.v1.secret.new(
      name=dockerRegistrySecretName,
      type='kubernetes.io/dockerconfigjson',
      data={
        local parsedDockerUri = parseUri(dockerRegistryUri),
        '.dockerconfigjson': std.base64(std.toString({
          auths: {
            [parsedDockerUri.proto + parsedDockerUri.host + ':' + parsedDockerUri.port]: {
              username: parsedDockerUri.username,
              password: parsedDockerUri.password,
              auth: std.base64(std.toString(parsedDockerUri.username+ ':' + parsedDockerUri.password)),
            },
          },
        })),
      }
    ).withNamespace(tasksNamespace),
    {
      local parsedDockerUri = parseUri(dockerRegistryUri),
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        labels: {
          app: 'docker-registry'
        },
        name: 'docker-registry',
        namespace: 'platform'
      },
      spec: {
        replicas: replicas,
        selector: {
          matchLabels: {
            app: 'docker-registry'
          }
        },
        template: {
          metadata: {
            labels: {
              app: 'docker-registry'
            },
            name: 'docker-registry'
          },
          spec: {
            containers: [
              {
                image: 'elasticio/registry:2.7.1-non-root',
                command: ['sh', '-c', 'sleep 3 && registry serve /etc/docker/registry/config.yml'],
                imagePullPolicy: 'Always',
                name: 'docker-registry',
                env: [
                  {
                    name: 'REGISTRY_HTTP_SECRET',
                    value: sharedSecret
                  },
                  {
                    name: 'REGISTRY_AUTH_HTPASSWD_REALM',
                    value: 'doesnotmatter'
                  },
                  {
                    name: 'REGISTRY_AUTH_HTPASSWD_PATH',
                    value: '/etc/htpasswd'
                  }
                ],
                volumeMounts: [
                  {
                    mountPath: '/var/lib/registry',
                    name: 'docker-storage',
                    subPath: 'docker'
                  }
                ],
                lifecycle: {
                  postStart: {
                    exec: {
                      command: [
                        'htpasswd',
                        '-cBb',
                        '/etc/htpasswd',
                        parsedDockerUri.username,
                        parsedDockerUri.password
                      ]
                    }
                  },
                  preStop: {
                    exec: {
                      command: ['/bin/sh', '-c', 'sleep 30; killall registry'],
                    },
                  },
                },
                livenessProbe: {
                  httpGet: {
                    port: 5000,
                    path: '/'
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
                    memory: '256',
                    cpu: 0.5
                  }
                },
                securityContext: {
                  privileged: false
                }
              },
            ],
            volumes: [
              {
                name: 'docker-storage',
                persistentVolumeClaim: {
                  claimName: 'platform-storage-slugs-volume-claim'
                }
              }
            ],
            dnsPolicy: 'ClusterFirst',
            imagePullSecrets: [{name: 'elasticiodevops'}],
            nodeSelector: {
              'elasticio-role': 'platform'
            }
          }
        },
        strategy: {
          rollingUpdate: {
            maxSurge: 1,
            maxUnavailable: 1
          },
          type: 'RollingUpdate'
        }
      }
    }
  ]
}
