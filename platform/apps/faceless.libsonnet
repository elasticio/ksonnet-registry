local k = import 'k.libsonnet';
local version = import 'elasticio/platform/version.json';

local terminationDelay = 30;
local app(replicas, port, appName, appType, credentials='') = [
    {
   kind: 'Deployment',
   apiVersion: 'apps/v1',
   metadata: {
     name: appName,
     namespace: 'platform',
     labels: {
       app: appName,
     },
   },
   spec: {
     replicas: replicas,
     selector: {
       matchLabels: {
         app: appName,
       },
     },
     template: {
       metadata: {
         name: appName,
         annotations: {
           "prometheus.io/scrape": "true",
           "prometheus.io/port": std.toString(port)
         },
         labels: {
           app: appName,
         },
       },
       spec: {
         affinity: {
           nodeAffinity: {
             requiredDuringSchedulingIgnoredDuringExecution: {
               nodeSelectorTerms: [
                 {
                   matchExpressions: [
                     {
                       key: 'elasticio-role',
                       operator: 'In',
                       values: [
                         'platform'
                       ]
                     }
                   ]
                 }
               ]
             }
           },
           podAntiAffinity: {
             requiredDuringSchedulingIgnoredDuringExecution: [
               {
                 labelSelector: {
                   matchLabels: {
                     app: appName
                   }
                 },
                 topologyKey: 'kubernetes.io/hostname'
               }
             ]
           }
         },
         securityContext: {
           fsGroup: 1000,
           runAsNonRoot: true,
           runAsUser: 1000
         },
         containers: [
           {
             name: appName,
             image: 'elasticio/faceless:' + version,
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
                 value: appName
               },
               {
                 name: 'APP_TYPE',
                 value: appType
               },
               {
                 name: 'LOG_LEVEL',
                 value: 'info'
               },
               {
                 name: 'TERMINATION_DELAY',
                 value: std.toString(terminationDelay / 2)
               },
               {
                 name: 'PORT',
                 value: std.toString(port)
               },
               {
                 name: 'TOKEN_REFRESHER_API',
                 value: 'http://faceless-token-refresher-service.platform.svc.cluster.local:11396'
               },
            ] +
            (if credentials != '' then [{
                 name: 'AUTH_CREDENTIALS',
                 value: credentials
             }] else []),
             livenessProbe: {
               httpGet: {
                 path: '/healthcheck',
                 port: port,
                 scheme: 'HTTP'
               }
             },
             readinessProbe: {
               httpGet: {
                 path: '/healthcheck',
                 port: port,
                 scheme: 'HTTP'
               }
             },
             ports: [
               {
                 containerPort: port,
                 protocol: 'TCP',
               },
             ],
             resources: {
               limits: {
                 memory: '2048Mi',
                 cpu: 1,
               },
               requests: {
                 memory: '512Mi',
                 cpu: 0.1,
               },
             },
             terminationMessagePath: '/dev/termination-log',
             terminationMessagePolicy: 'File',
             imagePullPolicy: 'IfNotPresent'
           },
         ],
         imagePullSecrets: [
           {
             name: 'elasticiodevops',
           },
         ],
         restartPolicy: 'Always',
         terminationGracePeriodSeconds: terminationDelay,
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
  }
];

local apiPort = 1396;
local tokenRefresherPort = 11396;
{
  app(
    apiReplicas = 2,
    credentials = ''
  )::
    app(apiReplicas, apiPort, 'faceless-api', 'api', credentials) +
    app(1, tokenRefresherPort, 'faceless-token-refresher', 'token-refresher', credentials) +
    [{
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        labels: {
          app: 'faceless-api'
        },
        name: 'faceless-api-service',
        namespace: 'platform'
      },
      spec: {
        ports: [
          {
            name: 'http',
            port: apiPort,
            protocol: 'TCP',
            targetPort: apiPort
          }
        ],
        selector: {
          app: 'faceless-api'
        },
        sessionAffinity: 'None',
        type: 'ClusterIP'
      }
    }, {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        labels: {
          app: 'faceless-token-refresher'
        },
        name: 'faceless-token-refresher-service',
        namespace: 'platform'
      },
      spec: {
        ports: [
          {
            name: 'http',
            port: tokenRefresherPort,
            protocol: 'TCP',
            targetPort: tokenRefresherPort
          }
        ],
        selector: {
          app: 'faceless-token-refresher'
        },
        type: 'ClusterIP'
      }
    }]
}
