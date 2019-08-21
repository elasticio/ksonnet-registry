// @apiVersion 0.0.1
// @name elastic.io.gitreceiver
// @param name string name
// @param docker_registry_uri string  uri (login port, host port) for docker registry

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local dockerRegistryUri = import 'param://docker_registry_uri';

platform.parts.gitreceiver(dockerRegistryUri)
