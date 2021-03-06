{
  networkPolicies(name):: [
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'platform-internal-traffic',
        namespace: 'platform',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {},
        ingress: [{
          from: [{
            namespaceSelector: {
              matchLabels: {
                name: 'platform'
              }
            }
          }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'tasks-to-platform',
        namespace: 'platform',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {
          matchExpressions: [{
            key: 'app',
            operator: 'In',
            values: ['ingress-nginx', 'webhooks', 'api', 'steward', 'platform-storage-slugs', 'maester']
          }]
        },
        ingress: [{
          from: [{
            namespaceSelector: {
              matchLabels: {
                name: 'tasks'
              }
            }
          }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'input-traffic',
        namespace: 'platform',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {
          matchLabels: {
            app: 'ingress-nginx'
          }
        },
        ingress: [{
          from: [{
            ipBlock: {
              cidr: '0.0.0.0/0'
            }
          }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
    	kind: 'NetworkPolicy',
    	metadata: {
        	name: 'allow-agents-to-platform-storage-slugs',
        	namespace: 'platform',
          annotations: {
           'meta.helm.sh/release-name': name,
           'meta.helm.sh/release-namespace': 'default'
          },
          labels: {
           'app.kubernetes.io/managed-by': 'Helm',
          }
    	},
    	spec: {
      	policyTypes: ['Ingress'],
				podSelector: {
        	matchLabels: {
          	app: 'platform-storage-slugs'
          }
        },
      	ingress: [{
        	from: [{
          	ipBlock: {
            	cidr: '0.0.0.0/0'
            }
          }]
        }]
    	}
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'allow-dockerd-to-docker-registry',
        namespace: 'platform',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {
          matchLabels: {
            app: 'docker-registry'
          }
        },
        ingress: [{
          from: [{
            ipBlock: {
              cidr: '0.0.0.0/0'
            }
          }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'monitoring-to-platform-traffic',
          namespace: 'platform',
          annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {},
          ingress: [{
            from: [{
              namespaceSelector: {
                matchLabels: {
                  name: 'monitoring'
                }
              }
            }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'platform-to-monitoring-traffic',
        namespace: 'monitoring',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {},
        ingress: [{
          from: [{
            namespaceSelector: {
              matchLabels: {
                name: 'platform'
              }
            }
          }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'monitoring-internal-traffic',
        namespace: 'monitoring',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {},
        ingress: [{
          from: [{
            namespaceSelector: {
              matchLabels: {
                name: 'monitoring'
              }
            }
          }]
        }]
      }
    },
    {
      apiVersion: 'networking.k8s.io/v1',
      kind: 'NetworkPolicy',
      metadata: {
        name: 'monitoring-ingress-traffic',
        namespace: 'monitoring',
        annotations: {
         'meta.helm.sh/release-name': name,
         'meta.helm.sh/release-namespace': 'default'
        },
        labels: {
         'app.kubernetes.io/managed-by': 'Helm',
        }
      },
      spec: {
        policyTypes: ['Ingress'],
        podSelector: {
          matchExpressions: [{
            key: 'app',
            operator: 'In',
            values: ['alertmanager', 'grafana', 'prometheus-server']
          }]
        },
        ingress: [{
          from: [{
            ipBlock: {
              cidr: '0.0.0.0/0'
            }
          }]
        }]
      }
    }
  ]
}
