// @apiVersion 0.0.1
// @name elastic.io.bran-write
// @param name string name
// @optionalParam bran_write_replicas number 0 bran-write replicas count
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local branWriteReplicas = import 'param://bran_write_replicas';
local mode = 'write';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

local branWrite = if branWriteReplicas < 1 then [] else platform.parts.bran(name, branWriteReplicas, mode);

branWrite
