// @apiVersion 0.0.1
// @name elastic.io.docker
// @param name string name
// @optionalParam docker_registry_replicas number 2 number of instances of docker registry
// @param docker_registry_secret_name string name of secret that will be used to autorize in docker secret
// @param docker_registry_uri string  uri (login port, host port) for docker registry
// @param docker_registry_http_secret string random string used in docker-registry crypto magic. No special requirements, just real random string
// @optionalParam s3_docker_url string  s3 compatible storage uri
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local dockerRegistryUri = import 'param://docker_registry_uri';
local dockerRegistrySecretName = import 'param://docker_registry_secret_name';
local dockerRegistryReplicas = import 'param://docker_registry_replicas';
local sharedSecret = import 'param://docker_registry_http_secret';
local replicas = import 'param://docker_registry_replicas';
local s3url = import 'param://s3_docker_url';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.dockerRegistry(name, dockerRegistryUri, dockerRegistrySecretName, sharedSecret, s3url, replicas)

