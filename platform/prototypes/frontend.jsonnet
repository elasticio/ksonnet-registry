// @apiVersion 0.0.1
// @name elastic.io.frontend
// @param name string name
// @optionalParam frontend_replicas number 1 frontend replicas count
// @optionalParam frontend_mem_limit number 2048 frontends pods mem limit MB
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local frontendReplicas = import 'param://frontend_replicas';
local memLimitMb = import 'param://frontend_mem_limit';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.frontend(name, frontendReplicas, memLimitMb)
