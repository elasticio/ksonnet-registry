// @apiVersion 0.0.1
// @name elastic.io.webhooks
// @param name string name
// @optionalParam webhooks_replicas number 1 webhooks replicas count
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local webhooksReplicas = import 'param://webhooks_replicas';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.webhooks(name, webhooksReplicas)
