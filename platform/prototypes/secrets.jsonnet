// @apiVersion 0.0.1
// @name elastic.io.secrets
// @param name string name
// @optionalParam docker_registry string https://index.docker.io/v1/ docker registry
// @param docker_username string docker registry username
// @param docker_password string docker registry password
// @param docker_email string docker registry email
// @optionalParam ingress_cert_name string ingress-elasticio-app-cert ingress tls cert secret name
// @param ingress_cert_crt string ingress base64 encoded tls cert certificate
// @param ingress_cert_key string ingress base64 encoded tls cert key
// @param gitreceiver_key string base64 encoded gitreceiver key
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local dockerEmail = import 'param://docker_email';
local dockerPassword = import 'param://docker_password';
local dockerRegistry = import 'param://docker_registry';
local dockerUsername = import 'param://docker_username';
local certName = import 'param://ingress_cert_name';
local tlsCert = import 'param://ingress_cert_crt';
local tlsKey = import 'param://ingress_cert_key';
local gitReceiverKey = import 'param://gitreceiver_key';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

[
  platform.parts.pullSecret(name, dockerUsername, dockerPassword, dockerEmail, dockerRegistry),
  platform.parts.tlsSecret(name, certName, tlsCert, tlsKey),
  platform.parts.gitreceiverKey(name, gitReceiverKey)
]
