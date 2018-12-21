# Elastic.io platform ksonnet registry

This repository cointains [ksonnet registry](https://ksonnet.io/docs/concepts#registry) of elastic.io platform components.
To use this repo you need [ksonnet](https://github.com/ksonnet/ksonnet/releases) CLI.

## Installation

Platform fresh installation.

### Configure

Configuration consists of 2 files

#### config.json

```js
{
    "accounts_password": "%accounts_password%",
    "amqp_uri": "%amqp_uri%",
    "api_uri": "%api_uri%",
    "api_service": "%api_service%",
    "appdirect_marketplace_url": "%appdirect_marketplace_url%",
    "appdirect_subscription_events_uri": "%appdirect_subscription_events_uri%",
    "apidocs_service": "%apidocs_service%",
    "apprunner_image": "%apprunner_image%",
    "company_name": "%company_name%",
    "component_mem_default": "%component_mem_default%",
    "cookie_max_age": "%cookie_max_age%",
    "debug_data_size_limit_mb": "%debug_data_size_limit_mb%",
    "default_driver_backend": "%default_driver_backend%",
    "default_per_contract_quota": "%default_per_contract_quota%",
    "elastic_search_uri": "%elastic_search_uri%",
    "enforce_quota": "%enforce_quota%",
    "environment": "%environment%",
    "env_password": "%env_password%",
    "external_api_uri": "%external_api_uri%",
    "external_app_uri": "%external_app_uri%",
    "external_gateway_uri": "%external_gateway_uri%",
    "external_steward_uri": "%external_steward_uri%",
    "frontend_service": "%frontend_service%",
    "gelf_address": "%gelf_address%",
    "gelf_host": "%gelf_host%",
    "gelf_port": "%gelf_port%",
    "gelf_protocol": "%gelf_protocol%",
    "git_receiver_host": "%git_receiver_host%",
    "hooks_data_password": "%hooks_data_password%",
    "intercom_access_token": "%intercom_access_token%",
    "intercom_app_id": "%intercom_app_id%",
    "intercom_secret_key": "%intercom_secret_key%",
    "kubernetes_rabbitmq_uri_sailor": "%kubernetes_rabbitmq_uri_sailor%",
    "kubernetes_slugs_base_url": "%kubernetes_slugs_base_url%",
    "mandrill_api_key": "%mandrill_api_key%",
    "marathon_uri": "%marathon_uri%",
    "message_crypto_iv": "%message_crypto_iv%",
    "message_crypto_password": "%message_crypto_password%",
    "mongo_uri": "%mongo_uri%",
    "node_env": "%node_env%",
    "petstore_api_host": "%petstore_api_host%",
    "predefined_users": "%predefined_users%",
    "quotas_uri": "%quotas_uri%",
    "rabbitmq_stats_login": "%rabbitmq_stats_login%",
    "rabbitmq_stats_pass": "%rabbitmq_stats_pass%",
    "rabbitmq_stats_uri": "%rabbitmq_stats_uri%",
    "rabbitmq_uri_boatswains": "%rabbitmq_uri_boatswains%",
    "rabbitmq_uri_sailor": "%rabbitmq_uri_sailor%",
    "rabbitmq_virtual_host": "%rabbitmq_virtual_host%",
    "rabbitmq_max_messages_per_queue": "%rabbitmq_max_messages_per_queue%",
    "rabbitmq_max_messages_mbytes_per_queue": "%rabbitmq_max_messages_mbytes_per_queue%",
    "raven_uri": "%raven_uri%",
    "secondary_marathon_uri": "%secondary_marathon_uri%",
    "service_account_password": "%service_account_password%",
    "service_account_username": "%service_account_username%",
    "session_mongo_uri": "%session_mongo_uri%",
    "slug_base_url": "%slug_base_url%",
    "steward_storage_uri": "%steward_storage_uri%",
    "steward_uri": "%steward_uri%",
    "suspended_task_max_messages_count": "%suspended_task_max_messages_count%",
    "suspend_watch_kubernetes_max_events": "%suspend_watch_kubernetes_max_events%",
    "team_name": "%team_name%",
    "tenant_code": "%tenant_code%",
    "tenant_domain": "%tenant_domain%",
    "tenant_name": "%tenant_name%",
    "user_amqp_crypto_password": "%user_amqp_crypto_password%",
    "user_api_crypto_password": "%user_api_crypto_password%",
    "webhooks_base_uri": "%webhooks_base_uri%",
    "webhooks_service": "%webhooks_service%",
    "tenant_admin_email": "%tenant_admin_email%",
    "tenant_admin_password": "%tenant_admin_password%",
    "log_level": "%log_level%"
}
```

Description for params can be found here: https://github.com/elasticio/k8s-deployment/blob/master/README.md

#### platform.json

```js
{
    "ingress_cert_name": "elasticio-ingress-certificate",
    "ingress_cert_crt": "%https_ssl_cert_crt_base64%",
    "ingress_cert_key": "%https_ssl_cert_key_base64%",
    "docker_username": "%docker_username%",
    "docker_password": "%docker_password%",
    "docker_email": "%docker_email%",
    "api_docs_image": "%api_docs_image%",
    "app_domain": "%app_domain%",
    "webhooks_domain": "%webhooks_domain%",
    "api_domain": "%api_domain%",
    "gitreceiver_key": "%gitrececeiver_pub_key_base64%",
    "ingress_name_default": "elasticio-ingress",
    "ingress_name_api_docs": "ingress-api-docs",
    "load_balancer_ip": "%load_balancer_ip%",
    "storage_slugs_pv_name": "platform-storage-slugs-volume",
    "nfs_server_address": "%pss_nfs_addr%",
    "nfs_share": "%pss_nfs_share%",
    "storage_slugs_lb_ip": "%pss_lb_ip%",
    "storage_slugs_size": "%pss_storgare_size%",
    "storage_slugs_sub_path_slugs": "slugs",
    "storage_slugs_sub_path_steward": "steward",
    "api_replicas": 2,
    "frontend_replicas": 2,
    "gold_dragon_coin_replicas": 2,
    "webhooks_replicas": 2,
    "storage_slugs_replicas": 2,
    "raven_replicas": 2,
    "steward_replicas": 2,
    "lookout_replicas": 2
}
```

* `ingress_cert_crt` and `ingress_cert_crt` - https ssl cert and key for app domains base64 encoded
* `gitreceiver_key` - public key for gitreceiver base64 encoded
* `docker_username`, `docker_password`, `docker_email` - docker registry credentials for registry where elasticio apps are.
* `app_domain`, `api-domain`, `webhooks_domain` - elasticio apps domains
* `load_balancer_ip` - external ip for ealsticio app
* `nfs_server_address` and `nfs_share` - configuration of NFS insyance for slugs component slugs storage
* `storage_slugs_lb_ip` - internal ip of platform-storage-slugs which is used for Agents
* `storage_slugs_size` - size of slugs storage (refer to Kubernetes PersistentVolume `size` field for format)
* `api_replicas`, `gold_dragon_coin_replicas`, `webhooks_replicas`, `storage_slugs_replicas`, `raven_replicas`, `steward_replicas`, `lookout_replicas` - number of instances for apps


### Init ksonnet project

```bash
ks init elasticio --skip-default-registries --env elasticio --context <kubectl_context>
cd elasticio
```

### Add elasticio registry

```bash
ks registry add elasticio github.com/elasticio/ksonnet-registry/tree/master
```

### Install elasticio packages

```bash
ks pkg install elasticio/platform@<current_elasticio_version>
```

### Generate ksonnet components

```bash
ks generate elastic.io.config config --values-file=config.json
ks generate elastic.io.gendry gendry
ks generate elastic.io.platform platform --values-file=platform.json
```

### Apply config

```bash
ks apply -c config elasticio --skip-gc --gc-tag elasticio0 --context <kubectl_context>
```

### Run gendry app to init elasticio platform

```bash
ks apply -c gendry elasticio --skip-gc --gc-tag elasticio0 --context <kubectl_context>
```
Wait until Gendry pod will be in completed status:
`kubectl --context <kubectl_context> --namespace platform get pods -lapp=gendry`
Output should be like this:
```
NAME           READY   STATUS      RESTARTS   AGE
gendry-qzjfp   0/1     Completed   0          1d
```

### Deploy platform apps

```bash
ks apply elasticio --gc-tag elasticio0 --context <kubectl_context>
```

## Update

Updating to the new version.

### Install new version of packages

```bash
ks pkg install elasticio/platform@<new_elasticio_version>
```

### Remove old components

```bash
ks component rm config
ks component rm gendry
ks component rm platform
```

### Generate new version of ksonnet components

```bash
ks generate elastic.io.config config --values-file=config.json
ks generate elastic.io.gendry gendry
ks generate elastic.io.platform platform --values-file=platform.json
```

### Update config

```bash
ks apply -c config elasticio --skip-gc --gc-tag elasticio0 --context <kubectl_context>
```

### Run gendry app to init elasticio platform

```bash
ks delete -c gendry elasticio --skip-gc --gc-tag elasticio0 --context <kubectl_context>
ks apply -c gendry elasticio --skip-gc --gc-tag elasticio0 --context <kubectl_context>
```

Wait until Gendry pod will be in completed status:
`kubectl --context <kubectl_context> --namespace platform get pods -lapp=gendry`
Output should be like this:

```
NAME           READY   STATUS      RESTARTS   AGE
gendry-qzjfp   0/1     Completed   0          1d
```

### Update platform apps

```bash
ks apply elasticio --gc-tag elasticio0 --context <kubectl_context>
```

## Known issues

List of known issues and workarounds

### Error `GET https://api.github.com/repos/elasticio/ksonnet-registry/commits/master: 403 API rate limit exceeded for %YOUR_IP_ADDRESS%`

Solution:
1. Create GitHub [personal access token](https://github.com/settings/tokens)
1. Set `GITHUB_TOKEN` env var, i.e. `GITHUB_TOKEN=<github_personal_token> ks registry add elasticio github.com/elasticio/ksonnet-registry/tree/master`

### ERROR Registry with name already exists

Solution: Remove ksonnet project dir and rerun installtation steps