// @apiVersion 0.0.1
// @name elastic.io.ingress
// @param name string name
// @optionalParam ingress_name_default string default-tenant-ingress ingress name
// @optionalParam ingress_name_api_docs string default-tenant-ingress-api-docs ingress name
// @param load_balancer_ip string ingress load balancer ip
// @optionalParam gitreceiver_ssh_port number 22 gitreceiver ssh port
// @optionalParam ingress_cert_name string ingress-elasticio-app-cert ingress tls cert secret name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';

local limitConnections = import 'param://ingress_limit_connections';
local ingressNameApiDocs = import 'param://ingress_name_api_docs';
local ingressNameDefault = import 'param://ingress_name_default';
local loadBalancerIP = import 'param://load_balancer_ip';
local apiDomain = import 'param://api_domain';
local appDomain = import 'param://app_domain';
local wehbooksDomain = import 'param://webhooks_domain';
local sshPort = import 'param://gitreceiver_ssh_port';
local certName = import 'param://ingress_cert_name';

platform.parts.ingressController() +
platform.parts.ingress(
  ingressNameDefault,
  ingressNameApiDocs,
  loadBalancerIP,
  sshPort,
  certName
)
