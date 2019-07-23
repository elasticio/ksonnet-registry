// @apiVersion 0.0.1
// @name elastic.io.raven
// @param name string name
// @optionalParam raven_replicas number 1 raven replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local ravenReplicas = import 'param://raven_replicas';

platform.parts.raven(ravenReplicas)
