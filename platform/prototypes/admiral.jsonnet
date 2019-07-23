// @apiVersion 0.0.1
// @name elastic.io.admiral
// @param name string name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';

platform.parts.admiral()
