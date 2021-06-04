{
  conf(name, ingressNameDefault, ingressNameApiDocs, loadBalancerIP, sshPort, certName):: [
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'ingress-loadbalancer',
          namespace: 'platform',
          annotations: {
           'meta.helm.sh/release-name': name,
           'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
           'app.kubernetes.io/managed-by': 'Helm',
           app: 'ingress-loadbalancer',
          }
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
