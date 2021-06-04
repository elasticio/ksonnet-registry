// @apiVersion 0.0.1
// @name elastic.io.storage-slugs-pv
// @param name string name
// @optionalParam storage_slugs_pv_gid number 1502 pv gid
// @optionalParam storage_slugs_pv_name string platform-storage-slugs-volume string platform storage slugs pv name
// @optionalParam storage_slugs_storage_type string nfs platform storage slugs storage type, nfs or azure
// @optionalParam storage_slugs_size string 1Ti platform storage slugs size
// @optionalParam nfs_server_address string 127.0.0.1 platform storage slugs nfs server address
// @optionalParam nfs_share string /pss platform storage slugs nfs share
// @optionalParam azure_storage_account_name string azure_account platform storage slugs azure storage account name
// @optionalParam azure_storage_account_key string azure_key storage slugs azure storage account keys
// @optionalParam azure_storage_share string azure_share storage slugs azure storage share
// @optionalParam platform_name string great-moraq platform name

local platform = import 'elasticio/platform/platform.libsonnet';
local pvGid = import 'param://storage_slugs_pv_gid';
local pvName = import 'param://storage_slugs_pv_name';
local storageSlugsStorageType = import 'param://storage_slugs_storage_type';
local pssStorage = import 'param://storage_slugs_size';
local nfsServer = import 'param://nfs_server_address';
local nfsShare = import 'param://nfs_share';
local azAccName = import 'param://azure_storage_account_name';
local azAccKey = import 'param://azure_storage_account_key';
local azShareName = import 'param://azure_storage_share';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

if storageSlugsStorageType == 'nfs' then platform.parts.storageSlugsPVNFS(name, pvName, nfsServer, nfsShare, pssStorage, pvGid) else if storageSlugsStorageType == 'azure' then platform.parts.storageSlugsPVAzure(name, pvName, azAccName, azAccKey, azShareName, pssStorage, pvGid) else []
