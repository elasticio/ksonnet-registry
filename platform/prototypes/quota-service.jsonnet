// @apiVersion 0.0.1
// @name elastic.io.quota-service
// @param name string name
// @optionalParam platform_name string great-moraq platform name

local platform = import 'elasticio/platform/platform.libsonnet';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.quotaService(name)
