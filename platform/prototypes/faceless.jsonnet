// @apiVersion 0.0.1
// @name elastic.io.faceless
// @param name string name
// @optionalParam faceless_replicas number 0 faceless replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local replicas = import 'param://faceless_replicas';

if replicas > 0 then platform.parts.faceless(replicas) else []
