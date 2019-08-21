// @apiVersion 0.0.1
// @name elastic.io.bran-read
// @param name string name
// @optionalParam bran_read_replicas number 1 bran-read replicas count

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local branReadReplicas = import 'param://bran_read_replicas';
local mode = 'read';

platform.parts.bran(branReadReplicas, mode)
