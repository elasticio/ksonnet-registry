// @apiVersion 0.0.1
// @name elastic.io.wiper
// @param name string name
// @optionalParam quota_service_uri string  quota_service_uri

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local quota_service_uri = import 'param://quota_service_uri';

local quotaServiceDisabled = quota_service_uri == '';

platform.parts.wiper(quotaServiceDisabled)
