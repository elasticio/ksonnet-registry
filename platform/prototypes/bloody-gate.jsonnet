// @apiVersion 0.0.1
// @name elastic.io.bloody-gate
// @param name string name
// NOTICE spaces between string and  ip address. Thats default value. Yes, I like ksonnet also. :(
// @optionalParam agent_entrypoint_ip string    ip address for vpn
// @optionalParam agent_ca_key string    private key for agents  CA
// @optionalParam agent_ca_cert string    certificate for agents CA

// Notice it's ok to use self-signed certificate + key for CA
// here is the way to generate it and install into platform.json file
//  openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 --days 365 -out certificate.pem -subj /C=DE/O=elastic.io/CN=ca.vpn-popeye.elastic.io/ST=Nordrhein-Westfalen/L=Bonn && cat ../../k8s-clusters/great-moraq/platform.json |  jq  '.agent_ca_cert |= $cert | .agent_ca_key |= $key' --arg cert "$(cat certificate.pem | base64)" --arg key "$(cat key.pem | base64)" > ../../k8s-clusters/great-moraq/platform.json

// PLEASE adjust parameters and file locations according to your requirements (--days, -subj, and so on)

local k = import 'k.libsonnet';

local platform = import 'elasticio/platform/platform.libsonnet';
local ipAddress = import 'param://agent_entrypoint_ip';
local caKey = import 'param://agent_ca_key';
local caCert = import 'param://agent_ca_cert';

if ipAddress != '' then platform.parts.bloodyGate(ipAddress, caCert, caKey) else []
