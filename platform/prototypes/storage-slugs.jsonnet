// @apiVersion 0.0.1
// @name elastic.io.storage-slugs
// @param name string name
// @optionalParam storage_slugs_replicas number 1 platform storage slugs replicas
// @optionalParam storage_slugs_pv_name string platform-storage-slugs-volume string platform storage slugs pv name
// @optionalParam storage_slugs_storage_type string nfs platform storage slugs storage type, nfs or azure
// @param storage_slugs_lb_ip string platform storage slugs load balancer internal ip address
// @optionalParam storage_slugs_size string 1Ti platform storage slugs size
// @optionalParam storage_slugs_sub_path_slugs string slugs sub path for slugs
// @optionalParam storage_slugs_sub_path_steward string steward sub path for steward
// @optionalParam storage_slugs_pv_gid number 1502 pv gid
// @optionalParam s3_slugs_url string  s3 compatible storage uri
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';

local pssLbIp = import 'param://storage_slugs_lb_ip';
local pssReplicas = import 'param://storage_slugs_replicas';
local pssStorage = import 'param://storage_slugs_size';
local slugsSubPath = import 'param://storage_slugs_sub_path_slugs';
local stewardSubPath = import 'param://storage_slugs_sub_path_steward';
local s3Url = import 'param://s3_slugs_url';
local storageSlugsStorageType = import 'param://storage_slugs_storage_type';
local isPV = storageSlugsStorageType != '';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

assert s3Url != '' || isPV : "s3_slugs_url or storage_slugs_storage_type must be set for platform-storage-slugs to work properly";

platform.parts.storageSlugs(name, pssReplicas, pssLbIp, pssStorage, slugsSubPath, stewardSubPath, s3Url, isPV)
