// @apiVersion 0.0.1
// @name elastic.io.raven
// @param name string name
// @optionalParam raven_replicas number 1 raven replicas count
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local ravenReplicas = import 'param://raven_replicas';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.raven(name, ravenReplicas)
