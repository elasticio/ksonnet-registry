// @apiVersion 0.0.1
// @name elastic.io.platform
// @param name string name
// @param api_docs_image string API docs image
// @optionalParam api_replicas number 1 api replicas count
// @optionalParam frontend_replicas number 1 frontend replicas count
// @optionalParam gold_dragon_coin_replicas number 1 gold dragon coin replicas count
// @optionalParam webhooks_replicas number 1 webhooks replicas count
// @optionalParam ingress_name string default-tenant-ingress ingress name
// @param load_balancer_ip string ingress load balancer ip
// @param app_domain string app domain
// @param api_domain string api domain
// @param webhooks_domain string webhooks domain
// @optionalParam gitreceiver_ssh_port number 22 gitreceiver ssh port
// @param ingress_cert_name string ingress tls cert secret name
// @param ingress_cert_crt string ingress base64 encoded tls cert certificate
// @param ingress_cert_key string ingress base64 encoded tls cert key
// @param gitreceiver_key string base64 encoded gitreceiver key
// @optionalParam docker_registry string https://index.docker.io/v1/ docker registry
// @param docker_username string docker regitry username
// @param docker_password string docker regitry password
// @param docker_email string docker regitry email
// @optionalParam storage_slugs_replicas number 1 platfrom storage slugs replicas
// @param storage_slugs_pv_name string platform storage slugs pv name
// @param nfs_server_address string platform storage slugs nfs server address
// @param nfs_share string platform storage slugs nfs share
// @param storage_slugs_lb_ip string platform storage slugs loadbalancer internal ip address
// @optionalParam storage_slugs_size string 1Ti platform storage slugs size
// @optionalParam storage_slugs_sub_path_slugs string slugs sub path for slugs
// @optionalParam storage_slugs_sub_path_steward string steward sub path for steward
// @optionalParam storage_slugs_pv_gid number 1502 pv gid

local k = import 'k.libsonnet';

local platform = import 'elasticio/platform/platform.libsonnet';

local apiDocsImage = import 'param://api_docs_image';
local apiReplicas = import 'param://api_replicas';
local frontendReplicas = import 'param://frontend_replicas';
local webhooksReplicas = import 'param://webhooks_replicas';
local goldDragonCoinReplicas = import 'param://gold_dragon_coin_replicas';
local ingressName = import 'param://ingress_name';
local loadBalancerIP = import 'param://load_balancer_ip';
local appDomain = import 'param://app_domain';
local apiDomain = import 'param://api_domain';
local wehbooksDomain = import 'param://webhooks_domain';
local sshPort = import 'param://gitreceiver_ssh_port';
local certName = import 'param://ingress_cert_name';
local dockerRegistry = import 'param://docker_registry';
local dockerUsername = import 'param://docker_username';
local dockerPassword = import 'param://docker_password';
local dockerEmail = import 'param://docker_email';
local tlsCert = import 'param://ingress_cert_crt';
local tlsKey = import 'param://ingress_cert_key';
local gitReceiverKey = import 'param://gitreceiver_key';
local pssReplicas = import 'param://storage_slugs_replicas';
local pvName = import 'param://storage_slugs_pv_name';
local nfsServer = import 'param://nfs_server_address';
local nfsShare = import 'param://nfs_share';
local pssLbIp = import 'param://storage_slugs_lb_ip';
local pssStorage = import 'param://storage_slugs_size';
local slugsSubPath = import 'param://storage_slugs_sub_path_slugs';
local stewardSubPath = import 'param://storage_slugs_sub_path_steward';
local pvGid = import 'param://storage_slugs_pv_gid';

[
  platform.parts.pullSecret(dockerUsername, dockerPassword, dockerEmail, dockerRegistry),
  platform.parts.tlsSecret(certName, tlsCert, tlsKey),
  platform.parts.gitreceiverKey(gitReceiverKey),
  platform.parts.lookout(),
  platform.parts.scheduler(),
] + platform.parts.admiral() +
  platform.parts.apiDocs(apiDocsImage) +
  platform.parts.api(apiReplicas) +
  platform.parts.fluentd() +
  platform.parts.frontend(frontendReplicas) +
  platform.parts.gitreceiver() +
  platform.parts.goldDagonCoin(goldDragonCoinReplicas) +
  platform.parts.ingressController() +
  platform.parts.ingress(ingressName, loadBalancerIP, appDomain, apiDomain, wehbooksDomain, sshPort, certName) +
  platform.parts.raven() +
  platform.parts.steward() +
  platform.parts.webhooks(webhooksReplicas) +
  platform.parts.wiper() +
  platform.parts.storageSlugs(pssReplicas, pvName, nfsServer, nfsShare, pssLbIp, pssStorage, slugsSubPath, stewardSubPath, pvGid)
