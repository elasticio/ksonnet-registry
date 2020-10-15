// @apiVersion 0.0.1
// @name elastic.io.frontend
// @param name string name
// @optionalParam frontend_replicas number 1 frontend replicas count
// @optionalParam frontend_mem_limit number 2048 frontends pods mem limit MB

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local frontendReplicas = import 'param://frontend_replicas';
local memLimitMb = import 'param://frontend_mem_limit';

platform.parts.frontend(frontendReplicas, memLimitMb)
