local k = import 'k.libsonnet';
local version = import 'elasticio/platform/version.json';

local app(replicas, port, appName, appType, terminationGracePeriodSeconds) = [
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        app: appName
      },
      name: appName + '-service',
      namespace: 'platform'
    },
    spec: {
      ports: [
        {
          name: 'http',
          port: port,
          protocol: 'TCP',
          targetPort: port
        }
      ],
      selector: {
        app: appName
      },
      sessionAffinity: 'None',
      type: 'ClusterIP'
    }
  },
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
                 value: std.toString(terminationGracePeriodSeconds / 2)
               },
               {
                 name: 'PORT',
                 value: std.toString(port)
               },
               {
                 name: 'AUTH_CREDENTIALS',
                 valueFrom: {
                   secretKeyRef: {
                     name: 'elasticio',
                     key: 'FACELESS_BASIC_AUTH_CREDENTIALS',
                   },
                 },
               },
             ],
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
         terminationGracePeriodSeconds: terminationGracePeriodSeconds,
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

{
  app(
    apiReplicas = 2,
    tokenRefresherReplicas = 1,
    apiPort = 1396,
    tokenRefresherPort = 11396,
    apiAppName = 'faceless-api',
    tokenRefresherAppName = 'faceless-token-refresher',
    terminationGracePeriodSeconds = 30,
  )::
    app(apiReplicas, apiPort, apiAppName, 'api', terminationGracePeriodSeconds) +
    app(tokenRefresherReplicas, tokenRefresherPort, tokenRefresherAppName, 'token-refresher', terminationGracePeriodSeconds)
}
