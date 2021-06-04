// @apiVersion 0.0.1
// @name elastic.io.faceless
// @param name string name
// @param faceless_encryption_key string data encryption key
// @optionalParam faceless_api_replicas number 0 faceless replicas count
// @optionalParam faceless_basic_auth_credentials string  login password pair for faceless
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local apiReplicas = import 'param://faceless_api_replicas';
local encryptionKey = import 'param://faceless_encryption_key';
local facelessCredentials = import 'param://faceless_basic_auth_credentials';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

if apiReplicas > 0 then platform.parts.faceless(name, encryptionKey, apiReplicas, facelessCredentials) else []
