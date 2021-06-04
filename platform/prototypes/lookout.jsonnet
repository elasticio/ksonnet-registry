// @apiVersion 0.0.1
// @name elastic.io.lookout
// @param name string name
// @optionalParam lookout_replicas number 1 lookout replicas count
// @optionalParam max_error_records_count string 1000 max error records count
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local lookoutReplicas = import 'param://lookout_replicas';
local maxErrorRecordsCount = import 'param://max_error_records_count';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.lookout(name, lookoutReplicas, maxErrorRecordsCount)
