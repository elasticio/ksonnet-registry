// @apiVersion 0.0.1
// @name elastic.io.maester
// @param name string name
// @optionalParam maester_redis_cluster_name string maester-cluster deploy redis
// @optionalParam maester_redis_sentinels string maester-redis-ha:26379 sentinels host:port,host:port
// @optionalParam maester_replicas number 3 maester_replicas
// @optionalParam deploy_redis string null deploy redis

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local maesterRedisClusterName = import 'param://maester_redis_cluster_name';
local maesterRedisSentinels = import 'param://maester_redis_sentinels';
local maesterReplicas = import 'param://maester_replicas';
local deployRedis = import 'param://deploy_redis';

local maesterRedis = if deployRedis != 'null' then
  platform.parts.maesterRedis(maesterRedisClusterName, 'maester-redis-ha')
else
  [];

platform.parts.maester(
  {
    name: maesterRedisClusterName,
    sentinels: std.map(function(sentinel) {
      local arr = std.split(sentinel, ':'),
      host: arr[0],
      port: arr[1],
    }, std.split(maesterRedisSentinels, ',')),
  },
  maesterReplicas
)
+ maesterRedis
