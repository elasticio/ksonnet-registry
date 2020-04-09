// @apiVersion 0.0.1
// @name elastic.io.faceless
// @param name string name
// @optionalParam faceless_api_replicas number 0 faceless replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local apiReplicas = import 'param://faceless_api_replicas';
local tokenRefresherReplicas = import 'param://faceless_token_refresher_replicas';

if apiReplicas > 0 then platform.parts.faceless(apiReplicas, tokenRefresherReplicas) else []
