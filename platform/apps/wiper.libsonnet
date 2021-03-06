local version = import 'elasticio/platform/version.json';

local quotaTxnResolver(name) = {
 apiVersion: 'batch/v1beta1',
 kind: 'CronJob',
 metadata: {
   name: 'quota-txn-resolver',
   namespace: 'platform',
   annotations: {
     'meta.helm.sh/release-name': name,
     'meta.helm.sh/release-namespace': 'default'
   },
   labels: {
     'app.kubernetes.io/managed-by': 'Helm',
     app: 'wiper',
     subapp: 'quota-txn-resolver',
   }
 },
 spec: {
   schedule: '* * * * *',
   concurrencyPolicy: 'Forbid',
   failedJobsHistoryLimit: 1,
   startingDeadlineSeconds: 200,
   jobTemplate: {
     metadata: {
       labels: {
         app: 'wiper',
         subapp: 'quota-txn-resolver',
       },
     },
     spec: {
       template: {
         metadata: {
           labels: {
             app: 'wiper',
             subapp: 'quota-txn-resolver',
           },
         },
         spec: {
           containers: [
             {
               name: 'quota-txn-resolver',
               image: 'elasticio/wiper:' + version,
               args: [
                 './node_modules/.bin/why-is-node-running',
                 '/app/index.js',
                 'quota-txn-resolver',
               ],
               env: [
                 {
                   name: 'APP_NAME',
                   value: 'wiper:quota-txn-resolver',
                 },
                 {
                   name: 'LOG_LEVEL',
                   value: 'trace'
                 },
                 {
                   name: 'ELASTICIO_API_URI',
                   valueFrom: {
                     secretKeyRef: {
                       key: 'API_URI',
                       name: 'elasticio',
                     },
                   },
                 },{
                   name: 'WIPER_PUSH_GATEWAY_URI',
                   valueFrom: {
                     secretKeyRef: {
                       key: 'PUSH_GATEWAY_URI',
                       name: 'elasticio',
                     },
                   },
                 },
               ],
               envFrom: [
                 {
                   secretRef: {
                     name: 'elasticio',
                   },
                 },
               ],
             },
           ],
           imagePullSecrets: [
             {
               name: 'elasticiodevops',
             },
           ],
           restartPolicy: 'OnFailure',
           nodeSelector: {
             'elasticio-role': 'platform',
           },
         },
       },
     },
   },
   successfulJobsHistoryLimit: 3,
 },
};

local monitorContractQuotaUsage(name) = {
  apiVersion: 'batch/v1beta1',
  kind: 'CronJob',
  metadata: {
    name: 'monitor-contract-quota-usage',
    namespace: 'platform',
    annotations: {
     'meta.helm.sh/release-name': name,
     'meta.helm.sh/release-namespace': 'default'
   },
   labels: {
     'app.kubernetes.io/managed-by': 'Helm',
     app: 'wiper',
      subapp: 'monitor-contract-quota-usage',
   }
  },
  spec: {
    schedule: '0 12 * * *',
    concurrencyPolicy: 'Replace',
    failedJobsHistoryLimit: 1,
    startingDeadlineSeconds: 200,
    jobTemplate: {
      metadata: {
        labels: {
          app: 'wiper',
          subapp: 'monitor-contract-quota-usage',
        },
      },
      spec: {
        template: {
          metadata: {
            labels: {
              app: 'wiper',
              subapp: 'monitor-contract-quota-usage',
            },
          },
          spec: {
            containers: [
              {
                name: 'monitor-contract-quota-usage',
                image: 'elasticio/wiper:' + version,
                args: [
                  'node',
                  '/app/index.js',
                  'monitor-contract-quota-usage',
                ],
                env: [
                  {
                    name: 'APP_NAME',
                    value: 'wiper:monitor-contract-quota-usage',
                  },
                  {
                    name: 'ELASTICIO_API_URI',
                    valueFrom: {
                      secretKeyRef: {
                        key: 'API_URI',
                        name: 'elasticio',
                      },
                    },
                  },{
                    name: 'WIPER_PUSH_GATEWAY_URI',
                    valueFrom: {
                      secretKeyRef: {
                        key: 'PUSH_GATEWAY_URI',
                        name: 'elasticio',
                      },
                    },
                  },
                ],
                envFrom: [
                  {
                    secretRef: {
                      name: 'elasticio',
                    },
                  },
                ],
              },
            ],
            imagePullSecrets: [
              {
                name: 'elasticiodevops',
              },
            ],
            restartPolicy: 'OnFailure',
            nodeSelector: {
              'elasticio-role': 'platform',
            },
          },
        },
      },
    },
    successfulJobsHistoryLimit: 3,
  },
};

local monitorWorkspaceQuotaUsage(name) = {
  apiVersion: 'batch/v1beta1',
  kind: 'CronJob',
  metadata: {
    name: 'monitor-workspace-quota-usage',
    namespace: 'platform',
    annotations: {
     'meta.helm.sh/release-name': name,
     'meta.helm.sh/release-namespace': 'default'
   },
   labels: {
     'app.kubernetes.io/managed-by': 'Helm',
     app: 'wiper',
      subapp: 'monitor-workspace-quota-usage',
   }
  },
  spec: {
    schedule: '0 12 * * *',
    concurrencyPolicy: 'Replace',
    failedJobsHistoryLimit: 1,
    startingDeadlineSeconds: 200,
    jobTemplate: {
      metadata: {
        labels: {
          app: 'wiper',
          subapp: 'monitor-workspace-quota-usage',
        },
      },
      spec: {
        template: {
          metadata: {
            labels: {
              app: 'wiper',
              subapp: 'monitor-workspace-quota-usage',
            },
          },
          spec: {
            containers: [
              {
                name: 'monitor-workspace-quota-usage',
                image: 'elasticio/wiper:' + version,
                args: [
                  'node',
                  '/app/index.js',
                  'monitor-workspace-quota-usage',
                ],
                env: [
                  {
                    name: 'APP_NAME',
                    value: 'wiper:monitor-workspace-quota-usage',
                  },
                  {
                    name: 'ELASTICIO_API_URI',
                    valueFrom: {
                      secretKeyRef: {
                        key: 'API_URI',
                        name: 'elasticio',
                      },
                    },
                  },{
                    name: 'WIPER_PUSH_GATEWAY_URI',
                    valueFrom: {
                      secretKeyRef: {
                        key: 'PUSH_GATEWAY_URI',
                        name: 'elasticio',
                      },
                    },
                  },
                ],
                envFrom: [
                  {
                    secretRef: {
                      name: 'elasticio',
                    },
                  },
                ],
              },
            ],
            imagePullSecrets: [
              {
                name: 'elasticiodevops',
              },
            ],
            restartPolicy: 'OnFailure',
            nodeSelector: {
              'elasticio-role': 'platform',
            },
          },
        },
      },
    },
    successfulJobsHistoryLimit: 3,
  },
};

local jobs(name) = [
    {
     apiVersion: 'batch/v1beta1',
     kind: 'CronJob',
     metadata: {
       name: 'clear-old-debug-tasks',
       namespace: 'platform',
       annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
       },
       labels: {
         'app.kubernetes.io/managed-by': 'Helm',
         app: 'wiper',
         subapp: 'clear-old-debug-tasks',
       }
     },
     spec: {
       schedule: '* * * * *',
       concurrencyPolicy: 'Forbid',
       startingDeadlineSeconds: 200,
       failedJobsHistoryLimit: 1,
       jobTemplate: {
         metadata: {
           labels: {
             app: 'wiper',
             subapp: 'clear-old-debug-tasks',
           },
         },
         spec: {
           template: {
             metadata: {
               labels: {
                 app: 'wiper',
                 subapp: 'clear-old-debug-tasks',
               },
             },
             spec: {
               containers: [
                 {
                   name: 'clear-old-debug-tasks',
                   image: 'elasticio/wiper:' + version,
                   args: [
                     './node_modules/.bin/why-is-node-running',
                     '/app/index.js',
                     'clear-old-debug-tasks',
                   ],
                   env: [
                     {
                       name: 'APP_NAME',
                       value: 'wiper:clear-old-debug-tasks',
                     },
                     {
                       name: 'LOG_LEVEL',
                       value: 'trace'
                     },
                     {
                       name: 'ELASTICIO_API_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'API_URI',
                           name: 'elasticio',
                         },
                       },
                     },{
                       name: 'WIPER_PUSH_GATEWAY_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'PUSH_GATEWAY_URI',
                           name: 'elasticio',
                         },
                       },
                     },
                   ],
                   envFrom: [
                     {
                       secretRef: {
                         name: 'elasticio',
                       },
                     },
                   ],
                 },
               ],
               imagePullSecrets: [
                 {
                   name: 'elasticiodevops',
                 },
               ],
               restartPolicy: 'OnFailure',
               nodeSelector: {
                 'elasticio-role': 'platform',
               },
             },
           },
         },
       },
       successfulJobsHistoryLimit: 3,
     },
    },
    {
     apiVersion: 'batch/v1beta1',
     kind: 'CronJob',
     metadata: {
       name: 'watch-and-finish-contract-delete',
       namespace: 'platform',
       annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
       },
       labels: {
         'app.kubernetes.io/managed-by': 'Helm',
         app: 'wiper',
         subapp: 'watch-and-finish-contract-delete',
       }
     },
     spec: {
       schedule: '*/3 * * * *',
       concurrencyPolicy: 'Replace',
       failedJobsHistoryLimit: 1,
       startingDeadlineSeconds: 200,
       jobTemplate: {
         metadata: {
           labels: {
             app: 'wiper',
             subapp: 'watch-and-finish-contract-delete',
           },
         },
         spec: {
           template: {
             metadata: {
               labels: {
                 app: 'wiper',
                 subapp: 'watch-and-finish-contract-delete',
               },
             },
             spec: {
               containers: [
                 {
                   name: 'watch-and-finish-contract-delete',
                   image: 'elasticio/wiper:' + version,
                   args: [
                     'node',
                     '/app/index.js',
                     'watch-and-finish-contract-delete',
                   ],
                   env: [
                     {
                       name: 'APP_NAME',
                       value: 'wiper:watch-and-finish-contract-delete',
                     },
                     {
                       name: 'ELASTICIO_API_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'API_URI',
                           name: 'elasticio',
                         },
                       },
                     },{
                       name: 'WIPER_PUSH_GATEWAY_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'PUSH_GATEWAY_URI',
                           name: 'elasticio',
                         },
                       },
                     },
                   ],
                   envFrom: [
                     {
                       secretRef: {
                         name: 'elasticio',
                       },
                     },
                   ],
                 },
               ],
               imagePullSecrets: [
                 {
                   name: 'elasticiodevops',
                 },
               ],
               restartPolicy: 'OnFailure',
               nodeSelector: {
                 'elasticio-role': 'platform',
               },
             },
           },
         },
       },
       successfulJobsHistoryLimit: 3,
     },
    },
    {
     apiVersion: 'batch/v1beta1',
     kind: 'CronJob',
     metadata: {
       name: 'watch-queues-overflow',
       namespace: 'platform',
       annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
       },
       labels: {
         'app.kubernetes.io/managed-by': 'Helm',
         app: 'wiper',
         subapp: 'watch-queues-overflow',
       }
     },
     spec: {
       schedule: '* * * * *',
       concurrencyPolicy: 'Forbid',
       failedJobsHistoryLimit: 1,
       startingDeadlineSeconds: 200,
       jobTemplate: {
         metadata: {
           labels: {
             app: 'wiper',
             subapp: 'watch-queues-overflow',
           },
         },
         spec: {
           template: {
             metadata: {
               labels: {
                 app: 'wiper',
                 subapp: 'watch-queues-overflow',
               },
             },
             spec: {
               containers: [
                 {
                   name: 'watch-queues-overflow',
                   image: 'elasticio/wiper:' + version,
                   args: [
                     'node',
                     '/app/index.js',
                     'watch-queues-overflow',
                   ],
                   env: [
                     {
                       name: 'APP_NAME',
                       value: 'wiper:watch-queues-overflow',
                     },
                     {
                       name: 'ELASTICIO_API_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'API_URI',
                           name: 'elasticio',
                         },
                       },
                     },{
                       name: 'WIPER_PUSH_GATEWAY_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'PUSH_GATEWAY_URI',
                           name: 'elasticio',
                         },
                       },
                     },
                   ],
                   envFrom: [
                     {
                       secretRef: {
                         name: 'elasticio',
                       },
                     },
                   ],
                 },
               ],
               imagePullSecrets: [
                 {
                   name: 'elasticiodevops',
                 },
               ],
               restartPolicy: 'OnFailure',
               nodeSelector: {
                 'elasticio-role': 'platform',
               },
             },
           },
         },
       },
       successfulJobsHistoryLimit: 3,
     },
    },
    {
     apiVersion: 'batch/v1beta1',
     kind: 'CronJob',
     metadata: {
       name: 'suspend-contracts',
       namespace: 'platform',
       annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
       },
       labels: {
         'app.kubernetes.io/managed-by': 'Helm',
          app: 'wiper',
         subapp: 'suspend-contracts',
       }
     },
     spec: {
       schedule: '* * * * *',
       concurrencyPolicy: 'Forbid',
       failedJobsHistoryLimit: 1,
       startingDeadlineSeconds: 200,
       jobTemplate: {
         metadata: {
           labels: {
             app: 'wiper',
             subapp: 'suspend-contracts',
           },
         },
         spec: {
           template: {
             metadata: {
               labels: {
                 app: 'wiper',
                 subapp: 'suspend-contracts',
               },
             },
             spec: {
               containers: [
                 {
                   name: 'suspend-contracts',
                   image: 'elasticio/wiper:' + version,
                   args: [
                     './node_modules/.bin/why-is-node-running',
                     '/app/index.js',
                     'suspend-contracts',
                   ],
                   env: [
                     {
                       name: 'APP_NAME',
                       value: 'wiper:suspend-contracts',
                     },
                     {
                       name: 'LOG_LEVEL',
                       value: 'trace'
                     },
                     {
                       name: 'ELASTICIO_API_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'API_URI',
                           name: 'elasticio',
                         },
                       },
                     },{
                       name: 'WIPER_PUSH_GATEWAY_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'PUSH_GATEWAY_URI',
                           name: 'elasticio',
                         },
                       },
                     },
                   ],
                   envFrom: [
                     {
                       secretRef: {
                         name: 'elasticio',
                       },
                     },
                   ],
                 },
               ],
               imagePullSecrets: [
                 {
                   name: 'elasticiodevops',
                 },
               ],
               restartPolicy: 'OnFailure',
               nodeSelector: {
                 'elasticio-role': 'platform',
               },
             },
           },
         },
       },
       successfulJobsHistoryLimit: 3,
     },
    },
    {
     apiVersion: 'batch/v1beta1',
     kind: 'CronJob',
     metadata: {
       name: 'stop-limited-flows',
       namespace: 'platform',
       annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
       },
       labels: {
         'app.kubernetes.io/managed-by': 'Helm',
          app: 'wiper',
         subapp: 'stop-limited-flows',
       }
     },
     spec: {
       schedule: '*/10 * * * *',
       concurrencyPolicy: 'Forbid',
       failedJobsHistoryLimit: 1,
       startingDeadlineSeconds: 200,
       jobTemplate: {
         metadata: {
           labels: {
             app: 'wiper',
             subapp: 'stop-limited-flows',
           },
         },
         spec: {
           template: {
             metadata: {
               labels: {
                 app: 'wiper',
                 subapp: 'stop-limited-flows',
               },
             },
             spec: {
               containers: [
                 {
                   name: 'stop-limited-flows',
                   image: 'elasticio/wiper:' + version,
                   args: [
                     'node',
                     '/app/index.js',
                     'stop-limited-flows',
                   ],
                   env: [
                     {
                       name: 'APP_NAME',
                       value: 'wiper:stop-limited-flows',
                     },
                     {
                       name: 'ELASTICIO_API_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'API_URI',
                           name: 'elasticio',
                         },
                       },
                     },{
                       name: 'WIPER_PUSH_GATEWAY_URI',
                       valueFrom: {
                         secretKeyRef: {
                           key: 'PUSH_GATEWAY_URI',
                           name: 'elasticio',
                         },
                       },
                     },
                   ],
                   envFrom: [
                     {
                       secretRef: {
                         name: 'elasticio',
                       },
                     },
                   ],
                 },
               ],
               imagePullSecrets: [
                 {
                   name: 'elasticiodevops',
                 },
               ],
               restartPolicy: 'OnFailure',
               nodeSelector: {
                 'elasticio-role': 'platform',
               },
             },
           },
         },
       },
       successfulJobsHistoryLimit: 3,
     },
    }
];

{
  app(params)::
    jobs(params.name) +
    (if !params.quotaServiceDisabled then [quotaTxnResolver(params.name)] else []) +
    (if !params.quotaServiceDisabled && !params.ironBankDisabled then [monitorContractQuotaUsage(params.name), monitorWorkspaceQuotaUsage(params.name)] else [])
}
