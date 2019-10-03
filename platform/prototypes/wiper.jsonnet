// @apiVersion 0.0.1
// @name elastic.io.wiper
// @param name string name
// @optionalParam iron_bank_enabled string true is iron-bank service enabled

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local quota_service_uri = 'http://quota-service-service.platform.svc.cluster.local:3002';
local iron_bank_enabled = import 'param://iron_bank_enabled';

platform.parts.wiper({
  quotaServiceDisabled: quota_service_uri == '',
  ironBankDisabled: iron_bank_enabled != 'true',
})
