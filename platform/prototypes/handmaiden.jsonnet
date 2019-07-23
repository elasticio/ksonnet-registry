// @apiVersion 0.0.1
// @name elastic.io.handmaiden
// @param name string name
// @param ingress_cert_name string ingress tls cert secret name

local k = import 'k.libsonnet';
local platform = import 'elasticio/platform/platform.libsonnet';
local certName = import 'param://ingress_cert_name';

platform.parts.handmaiden(certName)
