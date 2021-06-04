local k = import 'k.libsonnet';
local admiral = import 'elasticio/platform/apps/admiral.libsonnet';
local apiDocs = import 'elasticio/platform/apps/api-docs.libsonnet';
local api = import 'elasticio/platform/apps/api.libsonnet';
local bloodyGate = import 'elasticio/platform/apps/bloody-gate.libsonnet';
local dockerRegistry = import 'elasticio/platform/apps/docker.libsonnet';
local s3 = import 'elasticio/platform/apps/s3.libsonnet';
local fluentd = import 'elasticio/platform/apps/fluentd.libsonnet';
local faceless = import 'elasticio/platform/apps/faceless.libsonnet';
local frontend = import 'elasticio/platform/apps/frontend.libsonnet';
local gendry = import 'elasticio/platform/apps/gendry.libsonnet';
local cache = import 'elasticio/platform/apps/cache.libsonnet';
local gitreceiver = import 'elasticio/platform/apps/gitreceiver.libsonnet';
local goldDragonCoin = import 'elasticio/platform/apps/gold-dragon-coin.libsonnet';
local handmaiden = import 'elasticio/platform/apps/handmaiden.libsonnet';
local lookout = import 'elasticio/platform/apps/lookout.libsonnet';
local maester = import 'elasticio/platform/apps/maester.libsonnet';
local bran = import 'elasticio/platform/apps/bran.libsonnet';
local quotaService = import 'elasticio/platform/apps/quota-service.libsonnet';
local ironBank = import 'elasticio/platform/apps/iron-bank.libsonnet';
local raven = import 'elasticio/platform/apps/raven.libsonnet';
local scheduler = import 'elasticio/platform/apps/scheduler.libsonnet';
local steward = import 'elasticio/platform/apps/steward.libsonnet';
local storageSlugs = import 'elasticio/platform/apps/storage-slugs.libsonnet';
local webhooks = import 'elasticio/platform/apps/webhooks.libsonnet';
local wiper = import 'elasticio/platform/apps/wiper.libsonnet';
local gitreceiverKey = import 'elasticio/platform/keys/gitreceiver-key.libsonnet';
local pullSecret = import 'elasticio/platform/keys/pull-secret.libsonnet';
local tlsSecret = import 'elasticio/platform/keys/tls-secret.libsonnet';
local ingressController = import 'elasticio/platform/network/ingress-controller.libsonnet';
local ingress = import 'elasticio/platform/network/ingress.libsonnet';
local storageSlugsPVAzure = import 'elasticio/platform/storage/storage-slugs-pv-azure.libsonnet';
local storageSlugsPVNFS = import 'elasticio/platform/storage/storage-slugs-pv-nfs.libsonnet';
local podAffinitySpreadNodes = import 'elasticio/platform/tools/pod-affinity-spread-nodes.libsonnet';
local networkPolicies = import 'elasticio/platform/network/network-policies.libsonnet';
local version = import 'elasticio/platform/version.json';

{
  parts:: {
    // -------------------------------- //
    // --- Platform Secrets && Keys --- //
    // -------------------------------- //
    pullSecret(name, username, password, email, registry):: pullSecret.conf(name, username, password, email, registry),
    tlsSecret(name, certName, crt, key):: tlsSecret.conf(name, certName, crt, key),
    gitreceiverKey(name, key):: gitreceiverKey.conf(name, key),

    // ----------------------------- //
    // --- Network Configuration --- //
    // ----------------------------- //
    ingressController(name, error5xxPageUrl = ''):: ingressController.conf(name, error5xxPageUrl),
    ingress(
      name, 
      ingressNameDefault,
      ingressNameApiDocs,
      loadBalancerIP,
      sshPort,
      certName
    ):: ingress.conf(
      name, 
      ingressNameDefault,
      ingressNameApiDocs,
      loadBalancerIP,
      sshPort,
      certName
    ),

    // ----------------------------- //
    // --- Storage Configuration --- //
    // ----------------------------- //
    storageSlugsPVNFS(
      name, 
      pvName,
      server,
      path,
      storage='1Ti',
      pvGid=1502
    ):: storageSlugsPVNFS.conf(
      name, 
      pvName,
      server,
      path,
      storage,
      pvGid
    ),

    storageSlugsPVAzure(
      name, 
      pvName,
      accountName,
      accountKey,
      shareName,
      storage='1Ti',
      pvGid=1502
    ):: storageSlugsPVAzure.conf(
      name, 
      pvName,
      accountName,
      accountKey,
      shareName,
      storage,
      pvGid
    ),

    // ----------------------------- //
    // --- Platform Applications --- //
    // ----------------------------- //
    admiral(name, dockerRegistryUri, dockerRegistrySecret, facelessCreds):: admiral.app(name, dockerRegistryUri, dockerRegistrySecret, facelessCreds),
    apiDocs(name, image):: apiDocs.app(name, image),
    api(name, replicas, cpuRequest=0.1, cpuLimit=1, facelessCreds='', memLimitMb = 2048):: api.app(name, replicas, cpuRequest, cpuLimit, facelessCreds, memLimitMb),
    bloodyGate(name, ipAddress, caCert, caKey):: bloodyGate.app(name, ipAddress, caCert, caKey),
    cache(name):: cache.app(name),
    dockerRegistry(name, dockerRegistryUri, dockerRegistrySecret, sharedSecret, s3url, replicas):: dockerRegistry.app(name, dockerRegistryUri, dockerRegistrySecret, sharedSecret, s3url, replicas, 'tasks'),
    faceless(name, encryptionKey, apiReplicas, credentials=''):: faceless.app(name, encryptionKey, apiReplicas, credentials),
    fluentd(name, execGelfProto, execGelfHost, execGelfPort):: fluentd.app(name, execGelfProto, execGelfHost, execGelfPort),
    frontend(name, replicas, memLimitMb=2048, terminationGracePeriodSeconds=30):: frontend.app(name, replicas, memLimitMb, terminationGracePeriodSeconds),
    gendry(name):: gendry.app(name),
    gitreceiver(name, dockerRegistryUri):: gitreceiver.app(name, dockerRegistryUri),
    goldDragonCoin(name, replicas):: goldDragonCoin.app(name, replicas),
    handmaiden(name, secretName):: handmaiden.app(name, secretName, version),
    lookout(name, replicas, maxErrorRecordsCount):: lookout.app(name, replicas, maxErrorRecordsCount),
    bran(name, replicas, mode='read'):: bran.app(name, replicas, mode),
    quotaService(name):: quotaService.app(name),
    ironBank(name):: ironBank.app(name),
    raven(name, replicas):: raven.app(name, replicas),
    scheduler(name):: scheduler.app(name),
    steward(name, replicas, s3Uri=''):: steward.app(name, replicas, s3Uri),
    s3(name, accessKey, secretKey):: s3.app(name, accessKey, secretKey),
    webhooks(name, replicas):: webhooks.app(name, replicas),
    wiper(params):: wiper.app(params),

    storageSlugs(
      name, 
      replicas,
      lbIp,
      storage='1Ti',
      slugsSubPath='slugs',
      stewardSubPath='steward',
      s3Uri='',
      isPV=true
    ):: storageSlugs.app(
      name, 
      replicas,
      lbIp,
      storage,
      slugsSubPath,
      stewardSubPath,
      s3Uri,
      isPV
    ),

    maester(
      name, 
      maesterReplicas
    ):: maester.app(
      name, 
      version,
      maesterReplicas
    ),

    maesterRedis(
      name, 
      redisClusterName='maester-cluster',
      redisAppName='maester-redis-ha',
      redisReplicas=3,
      maxMemGB=1,
      storageSize='1Ti',
      redisDataDir='/data',
      redisConfigDir='/readonly-config',
      redisConfigMapName=redisAppName + '-configmap'
    ):: maester.redis(
      name, 
      redisClusterName,
      redisAppName,
      redisReplicas,
      maxMemGB,
      storageSize,
      redisDataDir,
      redisConfigDir,
      redisConfigMapName
    ),
    networkPolicies(name)::networkPolicies.networkPolicies(name)
  },
}
