// @apiVersion 0.0.1
// @name elastic.io.steward
// @param name string name
// @optionalParam steward_replicas number 1 steward replicas count
// @optionalParam s3_attachment_url string  s3 compatible storage uri

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local stewardReplicas = import 'param://steward_replicas';
local s3Url = import 'param://s3_attachment_url';

platform.parts.steward(stewardReplicas, s3Url)
