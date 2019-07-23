// @apiVersion 0.0.1
// @name elastic.io.lookout
// @param name string name
// @optionalParam lookout_replicas number 1 lookout replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local lookoutReplicas = import 'param://lookout_replicas';

platform.parts.lookout(lookoutReplicas)
