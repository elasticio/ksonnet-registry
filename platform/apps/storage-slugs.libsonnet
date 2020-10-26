local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local version = import 'elasticio/platform/version.json';
local attachmentsContainerPath = '/home/nginx/data/www/steward';

{
  app(replicas, lbIp, storage='1Ti', slugsSubPath='slugs', stewardSubPath='steward', s3Uri='', isPV=true):: [
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
										{
											name: 'S3_SLUGS_URI',
											value: s3Uri
										}
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
                  volumeMounts: (if isPV then
                    [
                      {
                        mountPath: '/home/nginx/data/www/slugs',
                        name: 'platform-storage-slugs-storage',
                        subPath: slugsSubPath,
                      },
                      {
                        mountPath: attachmentsContainerPath,
                        name: 'platform-storage-slugs-storage',
                        subPath: stewardSubPath,
                      },
                    ] else []
                  ),
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
              volumes: (if isPV then
                [
                  {
                    name: 'platform-storage-slugs-storage',
                    persistentVolumeClaim: {
                      claimName: 'platform-storage-slugs-volume-claim',
                    },
                  },
                ] else []
              ),
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
      (if isPV then {
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
      }),
      (if isPV then {
        apiVersion: 'batch/v1beta1',
        kind: 'CronJob',
        metadata: {
          name: 'remove-outdated-attachments',
          namespace: 'platform',
          labels: {
            app: 'platform-storage-slugs',
            subapp: 'remove-outdated-attachments',
          },
        },
        spec: {
          schedule: '0 */6 * * *',
          concurrencyPolicy: 'Forbid',
          failedJobsHistoryLimit: 1,
          successfulJobsHistoryLimit: 3,
          startingDeadlineSeconds: 600,
          jobTemplate: {
            metadata: {
              labels: {
                app: 'platform-storage-slugs',
                subapp: 'remove-outdated-attachments',
              },
            },
            spec: {
              template: {
                metadata: {
                  labels: {
                    app: 'platform-storage-slug',
                    subapp: 'remove-outdated-attachments',
                  },
                },
                spec: {
                  containers: [
                    {
                      name: 'remove-outdated-attachments',
                      image: 'elasticio/platform-storage-slugs:' + version,
                      command: [
                        '/usr/src/platform-storage-slugs/clean_attachments.sh',
                        attachmentsContainerPath
                      ],
                      env: [
                        {
                          name: 'APP_NAME',
                          value: 'platform-storage-slugs:remove-outdated-attachments'
                        },
                        {
                          name: 'ATTACHMENTS_LIFETIME_DAYS',
                          valueFrom: {
                            secretKeyRef: {
                              key: 'STEWARD_ATTACHMENTS_LIFETIME_DAYS',
                              name: 'elasticio'
                            }
                          }
                        }
                      ],
                      envFrom: [
                        {
                          secretRef: {
                            name: 'elasticio',
                          },
                        },
                      ],
                      volumeMounts: [
                        {
                          mountPath: attachmentsContainerPath,
                          name: 'platform-storage-slugs-storage',
                          subPath: stewardSubPath,
                        }
                      ]
                    }
                  ],
                  imagePullSecrets: [
                    {
                      name: 'elasticiodevops',
                    },
                  ],
                  volumes: [{
                    name: 'platform-storage-slugs-storage',
                    persistentVolumeClaim: {
                      claimName: 'platform-storage-slugs-volume-claim'
                    }
                  }],
                  restartPolicy: 'OnFailure',
                  nodeSelector: {
                    'elasticio-role': 'platform',
                  },
                },
              },
            },
          }
        }
      })
    ]
}
