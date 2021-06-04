// @apiVersion 0.0.1
// @name elastic.io.s3
// @param name string name
// @optionalParam s3_export_access_key string   access key for s3 used to authorize in minio
// @optionalParam s3_export_secret_key string   secret key for s3 used to authorize in minio
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local accessKey = import 'param://s3_export_access_key';
local secretKey = import 'param://s3_export_secret_key';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

if accessKey != '' && secretKey != '' then platform.parts.s3(name, accessKey, secretKey) else []

