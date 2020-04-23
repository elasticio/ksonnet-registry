// @apiVersion 0.0.1
// @name elastic.io.faceless
// @param name string name
// @optionalParam faceless_api_replicas number 0 faceless replicas count
// @optionalParam faceless_basic_auth_credentials string  login password pair for faceless

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local apiReplicas = import 'param://faceless_api_replicas';
local facelessCredentials = import 'param://faceless_basic_auth_credentials';

if apiReplicas > 0 then platform.parts.faceless(apiReplicas, facelessCredentials) else []
