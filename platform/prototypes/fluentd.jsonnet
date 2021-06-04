// @apiVersion 0.0.1
// @name elastic.io.fluentd
// @param name string name
// @optionalParam eio_exec_gelf_protocol string null gelf address for elasticio exec logs
// @optionalParam eio_exec_gelf_host string null gelf host for elasticio exec logs
// @optionalParam eio_exec_gelf_port string null gelf port for elasticio exec logs
// @optionalParam platform_name string great-moraq platform name for helm

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';

local eioExecGelfHost = import 'param://eio_exec_gelf_host';
local eioExecGelfPort = import 'param://eio_exec_gelf_port';
local eioExecGelfProto = import 'param://eio_exec_gelf_protocol';
local execGelfProto = if eioExecGelfProto == 'null' then false else eioExecGelfProto;
local execGelfHost = if eioExecGelfHost == 'null' then false else eioExecGelfHost;
local execGelfPort = if eioExecGelfPort == 'null' then false else eioExecGelfPort;
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.fluentd(name, execGelfProto, execGelfHost, execGelfPort)
