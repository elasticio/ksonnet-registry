// @apiVersion 0.0.1
// @name elastic.io.gitreceiver
// @param name string name
// @param docker_registry_uri string  uri (login port, host port) for docker registry
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local dockerRegistryUri = import 'param://docker_registry_uri';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.gitreceiver(name, dockerRegistryUri)
