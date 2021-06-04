// @apiVersion 0.0.1
// @name elastic.io.handmaiden
// @param name string name
// @optionalParam ingress_cert_name string ingress-elasticio-app-cert ingress tls cert secret name
// @optionalParam platform_name string great-moraq platform name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local certName = import 'param://ingress_cert_name';
local platformName = import 'param://platform_name';
local name = if platformName != "" then platformName else "great-moraq";

platform.parts.handmaiden(name, certName)
