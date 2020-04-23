// @apiVersion 0.0.1
// @name elastic.io.api
// @param name string name
// @optionalParam api_replicas number 1 api replicas count
// @optionalParam api_cpu_request number 0.1 API pods cpu request
// @optionalParam api_cpu_limit number 1 API pods cpu limit
// important two spaces after `string` word in next line
// @optionalParam faceless_basic_auth_credentials string  login password pair for faceless

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';

local apiReplicas = import 'param://api_replicas';
local apiCpuLimit = import 'param://api_cpu_limit';
local apiCpuRequest = import 'param://api_cpu_request';
local facelessCredentials = import 'param://faceless_basic_auth_credentials';

platform.parts.api(apiReplicas, apiCpuRequest, apiCpuLimit, facelessCredentials)
