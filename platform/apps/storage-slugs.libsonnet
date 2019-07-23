local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  app(replicas, lbIp, storage='1Ti', slugsSubPath='slugs', stewardSubPath='steward'):: [
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
            spec: podAffinitySpreadNodes.call('platform-storage-slugs') + {
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
                  lifecycle: {
                    preStop: {
                      exec: {
                        command: ['/bin/sh', '-c', 'sleep 30; /usr/sbin/nginx -s quit'],
                      },
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
          type: 'ClusterIP',
          sessionAffinity: 'None',
          selector: {
            app: 'platform-storage-slugs',
          },
          ports: [
            {
              name: '9999',
              port: 9999,
              protocol: 'TCP',
              targetPort: 8000,
              nodePort: null,
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
          externalTrafficPolicy: 'Local',
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
}
