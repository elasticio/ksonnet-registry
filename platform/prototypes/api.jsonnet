// @apiVersion 0.0.1
// @name elastic.io.api
// @param name string name
// @optionalParam api_replicas number 1 api replicas count
// @optionalParam api_cpu_request number 0.1 API pods cpu request
// @optionalParam api_cpu_limit number 1 API pods cpu limit

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';

local apiReplicas = import 'param://api_replicas';
local apiCpuLimit = import 'param://api_cpu_limit';
local apiCpuRequest = import 'param://api_cpu_request';

platform.parts.api(apiReplicas, apiCpuRequest, apiCpuLimit)
