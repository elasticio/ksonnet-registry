// @apiVersion 0.0.1
// @name elastic.io.webhooks
// @param name string name
// @optionalParam webhooks_replicas number 1 webhooks replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local webhooksReplicas = import 'param://webhooks_replicas';

platform.parts.webhooks(webhooksReplicas)
