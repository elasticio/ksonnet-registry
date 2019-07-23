// @apiVersion 0.0.1
// @name elastic.io.frontend
// @param name string name
// @optionalParam frontend_replicas number 1 frontend replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local frontendReplicas = import 'param://frontend_replicas';

platform.parts.frontend(frontendReplicas)
