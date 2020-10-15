// @apiVersion 0.0.1
// @name elastic.io.admiral
// @param name string name
// @param docker_registry_secret_name string name of secret that will be used to autorize in docker secret
// @param docker_registry_uri string  uri (login port, host port) for docker registry


local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local dockerRegistryUri = import 'param://docker_registry_uri';
local dockerRegistrySecretName = import 'param://docker_registry_secret_name';
local facelessCredentials = import 'param://faceless_basic_auth_credentials';

platform.parts.admiral(dockerRegistryUri, dockerRegistrySecretName, facelessCredentials)
