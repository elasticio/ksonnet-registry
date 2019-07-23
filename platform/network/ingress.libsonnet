{
  conf(ingressNameDefault, ingressNameApiDocs, loadBalancerIP, appDomain, apiDomain, webhooksDomain, sshPort, certName, limitConnections):: [
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          labels: {
            app: 'ingress-loadbalancer',
          },
          name: 'ingress-loadbalancer',
          namespace: 'platform',
        },
        spec: {
          type: 'LoadBalancer',
          externalTrafficPolicy: 'Local',
          loadBalancerIP: loadBalancerIP,
          selector: {
            app: 'ingress-nginx',
          },
          ports: [
            {
              name: 'http',
              port: 80,
              protocol: 'TCP',
              targetPort: 80,
            },
            {
              name: 'https',
              port: 443,
              protocol: 'TCP',
              targetPort: 443,
            },
            {
              name: 'ssh',
              port: sshPort,
              protocol: 'TCP',
              targetPort: 22,
            },
          ],
        },
      },
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: ingressNameDefault,
          namespace: 'platform',
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/affinity': 'cookie',
            'nginx.ingress.kubernetes.io/proxy-body-size': '10m',
          } + if limitConnections > 0 then { 'nginx.ingress.kubernetes.io/limit-connections': std.toString(limitConnections) } else {},
        },
        spec: {
          tls: [
            {
              secretName: certName,
              hosts: [
                appDomain,
                apiDomain,
                webhooksDomain,
              ],
            },
          ],
          rules: [
            {
              host: apiDomain,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'api-service',
                      servicePort: 9000,
                    },
                  },
                ],
              },
            },
            {
              host: appDomain,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'frontend-service',
                      servicePort: 8000,
                    },
                  },
                ],
              },
            },
            {
              host: webhooksDomain,
              http: {
                paths: [
                  {
                    backend: {
                      serviceName: 'webhooks-service',
                      servicePort: 5000,
                    },
                  },
                ],
              },
            },
          ],
        },
      },
      {
        apiVersion: 'extensions/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: ingressNameApiDocs,
          namespace: 'platform',
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/rewrite-target': '/',
            'nginx.ingress.kubernetes.io/proxy-redirect-from': '/',
            'nginx.ingress.kubernetes.io/proxy-redirect-to': '/docs/',
            'nginx.ingress.kubernetes.io/limit-connections': '200',
            'nginx.ingress.kubernetes.io/proxy-body-size': '1k',
          },
        },
        spec: {
          rules: [
            {
              host: apiDomain,
              http: {
                paths: [
                  {
                    path: '/docs/',
                    backend: {
                      serviceName: 'api-docs-service',
                      servicePort: 8000,
                    },
                  },
                ],
              },
            },
          ],
        },
      },
    ]
}
