// @apiVersion 0.0.1
// @name elastic.io.bran-write
// @param name string name
// @optionalParam bran_write_replicas number 1 bran-write replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local branWriteReplicas = import 'param://bran_write_replicas';
local mode = 'write';

platform.parts.bran(branWriteReplicas, mode)
