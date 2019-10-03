{
  conf(ingressNameDefault, ingressNameApiDocs, loadBalancerIP, sshPort, certName):: [
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
      }
    ]
}
