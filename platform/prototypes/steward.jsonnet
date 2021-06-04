// @apiVersion 0.0.1
// @name elastic.io.steward
// @param name string name
// @optionalParam steward_replicas number 1 steward replicas count
// @optionalParam s3_attachment_url string  s3 compatible storage uri
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local stewardReplicas = import 'param://steward_replicas';
local s3Url = import 'param://s3_attachment_url';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.steward(name, stewardReplicas, s3Url)
