// @apiVersion 0.0.1
// @name elastic.io.platform
// @param name string name
// @param api_docs_image string API docs image
// @optionalParam api_replicas number 1 api replicas count
// @optionalParam frontend_replicas number 1 frontend replicas count
// @optionalParam gold_dragon_coin_replicas number 1 gold dragon coin replicas count
// @optionalParam webhooks_replicas number 1 webhooks replicas count
// @optionalParam ingress_name_default string default-tenant-ingress ingress name
// @optionalParam ingress_name_api_docs string default-tenant-ingress-api-docs ingress name
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
// @param docker_username string docker registry username
// @param docker_password string docker registry password
// @param docker_email string docker registry email
// @optionalParam storage_slugs_replicas number 1 platfrom storage slugs replicas
// @optionalParam storage_slugs_pv_name string platform-storage-slugs-volume string platform storage slugs pv name
// @optionalParam storage_slugs_storage_type string nfs platform storage slugs storage type, nfs or azure
// @optionalParam nfs_server_address string 127.0.0.1 platform storage slugs nfs server address
// @optionalParam nfs_share string /pss platform storage slugs nfs share
// @optionalParam azure_storage_account_name string azure_account platform storage slugs azure storage account name
// @optionalParam azure_storage_account_key string azure_key storage slugs azure storage account keys
// @optionalParam azure_storage_share string azure_share storage slugs azure storage share
// @param storage_slugs_lb_ip string platform storage slugs loadbalancer internal ip address
// @optionalParam storage_slugs_size string 1Ti platform storage slugs size
// @optionalParam storage_slugs_sub_path_slugs string slugs sub path for slugs
// @optionalParam storage_slugs_sub_path_steward string steward sub path for steward
// @optionalParam storage_slugs_pv_gid number 1502 pv gid
// @optionalParam raven_replicas number 1 raven replicas count
// @optionalParam lookout_replicas number 1 lookout replicas count
// @optionalParam steward_replicas number 1 steward replicas count
// @optionalParam ingress_limit_connections number 0 parallel connections limit for ingress

local k = import 'k.libsonnet';

local platform = import 'elasticio/platform/platform.libsonnet';

local apiDocsImage = import 'param://api_docs_image';
local apiReplicas = import 'param://api_replicas';
local frontendReplicas = import 'param://frontend_replicas';
local webhooksReplicas = import 'param://webhooks_replicas';
local goldDragonCoinReplicas = import 'param://gold_dragon_coin_replicas';
local ingressNameDefault = import 'param://ingress_name_default';
local ingressNameApiDocs = import 'param://ingress_name_api_docs';
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
local ravenReplicas = import 'param://raven_replicas';
local lookoutReplicas = import 'param://lookout_replicas';
local stewardReplicas = import 'param://steward_replicas';
local limitConnections = import 'param://ingress_limit_connections';
local storageSlugsStorageType = import 'param://storage_slugs_storage_type';
local azAccName = import 'param://azure_storage_account_name';
local azAccKey = import 'param://azure_storage_account_key';
local azShareName = import 'param://azure_storage_share';

local pssPv = if storageSlugsStorageType == 'nfs' then platform.parts.storageSlugsPVNfs(pvName, nfsServer, nfsShare, pssStorage, pvGid) else if storageSlugsStorageType == 'azure' then platform.parts.storageSlugsPVAzure(pvName, azAccName, azAccKey, azShareName, pssStorage, pvGid) else null;

assert std.isArray(pssPv);

[
  platform.parts.pullSecret(dockerUsername, dockerPassword, dockerEmail, dockerRegistry),
  platform.parts.tlsSecret(certName, tlsCert, tlsKey),
  platform.parts.gitreceiverKey(gitReceiverKey),
  platform.parts.lookout(lookoutReplicas),
  platform.parts.scheduler(),
] + platform.parts.admiral() +
  platform.parts.apiDocs(apiDocsImage) +
  platform.parts.api(apiReplicas) +
  platform.parts.fluentd() +
  platform.parts.frontend(frontendReplicas) +
  platform.parts.gitreceiver() +
  platform.parts.goldDagonCoin(goldDragonCoinReplicas) +
  platform.parts.ingressController() +
  platform.parts.ingress(ingressNameDefault, ingressNameApiDocs, loadBalancerIP, appDomain, apiDomain, wehbooksDomain, sshPort, certName, limitConnections) +
  platform.parts.raven(ravenReplicas) +
  platform.parts.steward(stewardReplicas) +
  platform.parts.webhooks(webhooksReplicas) +
  platform.parts.handmaiden(certName) +
  platform.parts.wiper() +
  pssPv +
  platform.parts.storageSlugs(pssReplicas, pssLbIp, pssStorage, slugsSubPath, stewardSubPath)
