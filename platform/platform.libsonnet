local k = import 'k.libsonnet';
local admiral = import 'elasticio/platform/apps/admiral.libsonnet';
local apiDocs = import 'elasticio/platform/apps/api-docs.libsonnet';
local api = import 'elasticio/platform/apps/api.libsonnet';
local bloodyGate = import 'elasticio/platform/apps/bloody-gate.libsonnet';
local dockerRegistry = import 'elasticio/platform/apps/docker.libsonnet';
local s3 = import 'elasticio/platform/apps/s3.libsonnet';
local fluentd = import 'elasticio/platform/apps/fluentd.libsonnet';
local frontend = import 'elasticio/platform/apps/frontend.libsonnet';
local gendry = import 'elasticio/platform/apps/gendry.libsonnet';
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
local version = import 'elasticio/platform/version.json';

{
  parts:: {
    // -------------------------------- //
    // --- Platform Secrets && Keys --- //
    // -------------------------------- //
    pullSecret(username, password, email, registry):: pullSecret.conf(username, password, email, registry),
    tlsSecret(name, crt, key):: tlsSecret.conf(name, crt, key),
    gitreceiverKey(key):: gitreceiverKey.conf(key),

    // ----------------------------- //
    // --- Network Configuration --- //
    // ----------------------------- //
    ingressController():: ingressController.conf(),
    ingress(
      ingressNameDefault,
      ingressNameApiDocs,
      loadBalancerIP,
      sshPort,
      certName
    ):: ingress.conf(
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
      pvName,
      server,
      path,
      storage='1Ti',
      pvGid=1502
    ):: storageSlugsPVNFS.conf(
      pvName,
      server,
      path,
      storage,
      pvGid
    ),

    storageSlugsPVAzure(
      pvName,
      accountName,
      accountKey,
      shareName,
      storage='1Ti',
      pvGid=1502
    ):: storageSlugsPVAzure.conf(
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
    admiral(dockerRegistryUri, dockerRegistrySecret):: admiral.app(dockerRegistryUri, dockerRegistrySecret),
    apiDocs(image):: apiDocs.app(image),
    api(replicas, cpuRequest=0.1, cpuLimit=1, terminationGracePeriodSeconds=30):: api.app(replicas, cpuRequest, cpuLimit, terminationGracePeriodSeconds),
    bloodyGate(ipAddress, caCert, caKey):: bloodyGate.app(ipAddress, caCert, caKey),
    dockerRegistry(dockerRegistryUri, dockerRegistrySecret, sharedSecret, s3url, replicas):: dockerRegistry.app(dockerRegistryUri, dockerRegistrySecret, sharedSecret, s3url, replicas, 'tasks'),
    fluentd(execGelfProto, execGelfHost, execGelfPort):: fluentd.app(execGelfProto, execGelfHost, execGelfPort),
    frontend(replicas, terminationGracePeriodSeconds=30):: frontend.app(replicas, terminationGracePeriodSeconds),
    gendry():: gendry.app(),
    gitreceiver(dockerRegistryUri):: gitreceiver.app(dockerRegistryUri),
    goldDragonCoin(replicas):: goldDragonCoin.app(replicas),
    handmaiden(secretName):: handmaiden.app(secretName, version),
    lookout(replicas, maxErrorRecordsCount):: lookout.app(replicas, maxErrorRecordsCount),
    bran(replicas, mode='read'):: bran.app(replicas, mode),
    quotaService():: quotaService.app(),
    ironBank():: ironBank.app(),
    raven(replicas):: raven.app(replicas),
    scheduler():: scheduler.app(),
    steward(replicas, s3Uri=''):: steward.app(replicas, s3Uri),
    s3(accessKey, secretKey):: s3.app(accessKey, secretKey),
    webhooks(replicas):: webhooks.app(replicas),
    wiper(params):: wiper.app(params),

    storageSlugs(
      replicas,
      lbIp,
      storage='1Ti',
      slugsSubPath='slugs',
      stewardSubPath='steward',
      s3Uri=''
    ):: storageSlugs.app(
      replicas,
      lbIp,
      storage,
      slugsSubPath,
      stewardSubPath,
      s3Uri
    ),

    maester(
      maesterReplicas
    ):: maester.app(
      version,
      maesterReplicas
    ),

    maesterRedis(
      redisClusterName='maester-cluster',
      redisAppName='maester-redis-ha',
      redisReplicas=3,
      maxMemGB=1,
      storageSize='1Ti',
      redisDataDir='/data',
      redisConfigDir='/readonly-config',
      redisConfigMapName=redisAppName + '-configmap',
    ):: maester.redis(
      redisClusterName,
      redisAppName,
      redisReplicas,
      maxMemGB,
      storageSize,
      redisDataDir,
      redisConfigDir,
      redisConfigMapName,
    ),

  },
}
