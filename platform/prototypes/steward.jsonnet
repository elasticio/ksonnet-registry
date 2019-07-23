// @apiVersion 0.0.1
// @name elastic.io.steward
// @param name string name
// @optionalParam steward_replicas number 1 steward replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local stewardReplicas = import 'param://steward_replicas';

platform.parts.steward(stewardReplicas)
