// @apiVersion 0.0.1
// @name elastic.io.maester
// @param name string name
// @optionalParam maester_replicas number 2 maester_replicas
// @optionalParam maester_enabled string false is maester service enabled

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local maesterReplicas = import 'param://maester_replicas';
local maesterEnabled = import 'param://maester_enabled';

local maester = if maesterEnabled != 'true' then [] else platform.parts.maester(maesterReplicas);

maester
