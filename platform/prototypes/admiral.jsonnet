// @apiVersion 0.0.1
// @name elastic.io.admiral
// @param name string name
// @param docker_registry_secret_name string name of secret that will be used to autorize in docker secret
// @param docker_registry_uri string  uri (login port, host port) for docker registry
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local dockerRegistryUri = import 'param://docker_registry_uri';
local dockerRegistrySecretName = import 'param://docker_registry_secret_name';
local facelessCredentials = import 'param://faceless_basic_auth_credentials';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.admiral(name, dockerRegistryUri, dockerRegistrySecretName, facelessCredentials)
