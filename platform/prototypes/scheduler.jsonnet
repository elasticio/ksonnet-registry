// @apiVersion 0.0.1
// @name elastic.io.scheduler
// @param name string name
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.scheduler(name)
