// @apiVersion 0.0.1
// @name elastic.io.bran-read
// @param name string name
// @optionalParam bran_read_replicas number 0 bran-read replicas count
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local branReadReplicas = import 'param://bran_read_replicas';
local mode = 'read';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

local branRead = if branReadReplicas < 1 then [] else platform.parts.bran(name, branReadReplicas, mode);

branRead
