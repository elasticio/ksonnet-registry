// @apiVersion 0.0.1
// @name elastic.io.quota-service
// @param name string name
// @optionalParam quota_service_uri string  quota_service_uri
// @param ingress_cert_name string ingress tls cert secret name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local quota_service_uri = import 'param://quota_service_uri';
local certName = import 'param://ingress_cert_name';

local quotaServiceDisabled = quota_service_uri == '';
local quotaService = if quotaServiceDisabled then [] else platform.parts.quotaService(certName);

quotaService
