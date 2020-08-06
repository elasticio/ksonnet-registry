// @apiVersion 0.0.1
// @name elastic.io.config
// @param name string name
// @param accounts_password string accounts_password
// @optionalParam allow_empty_contract_after_the_last_user_removing string false allow_empty_contract_after_the_last_user_removing
// @param amqp_uri string amqp_uri
// @optionalParam appdirect_marketplace_url string  appdirect_marketplace_url
// @optionalParam appdirect_subscription_events_uri string  appdirect_subscription_events_uri
// @optionalParam appdirect_login string  appdirect_login
// @optionalParam appdirect_password string  appdirect_password
// @param admiral_service_account_username string admiral_service_account_username
// @param admiral_service_account_password string admiral_service_account_password
// @optionalParam apprunner_image string elasticio/apprunner:production apprunner_image
// @optionalParam bran_clickhouse_uri string  bran_clickhouse_uri
// @optionalParam bran_enabled string false is bran service enabled
// @optionalParam bran_prefetch_count string 10 bran_prefetch_count
// @param certificate_store_encryption_password string certificate_store_encryption_password
// @param company_name string company_name
// @optionalParam component_cpu string 0.08 component_cpu
// @optionalParam component_cpu_limit number 1 component_cpu_limit
// @optionalParam component_mem_default number 90 component_mem_default
// @optionalParam component_mem_default_limit number 256 component_mem_default_limit
// @optionalParam component_mem_java number 512 component_mem_java
// @optionalParam component_mem_java_limit number 512 component_mem_java_limit
// @optionalParam cookie_max_age number 604800000 cookie_max_age
// @optionalParam debug_data_size_limit_mb number 5 debug_data_size_limit_mb
// @optionalParam default_per_contract_quota number 5 default_per_contract_quota
// @param elastic_search_uri string elastic_search_uri
// @optionalParam enforce_quota string false enforce_quota
// @param environment string environment
// @param env_password string env_password
// @param external_api_uri string external_api_uri
// @param external_app_uri string external_app_uri
// @param external_gateway_uri string external_gateway_uri
// @param frontend_service_account_username string frontend_service_account_username
// @param frontend_service_account_password string frontend_service_account_password
// @param gelf_address string gelf_address
// @param gelf_host string gelf_host
// @optionalParam gelf_port number 12201 gelf_port
// @optionalParam gelf_protocol string udp gelf_protocol
// @optionalParam gendry_service_accounts string  gendry_service_accounts
// @param git_receiver_host string git_receiver_host
// @optionalParam limited_workspace_flow_ttl_in_minutes string 10 limited_workspace_flow_ttl_in_minutes
// @param hooks_data_password string hooks_data_password
// @optionalParam ignore_container_errors string  ignore_container_errors
// @optionalParam intercom_access_token string  intercom_access_token
// @optionalParam intercom_app_id string  intercom_app_id
// @optionalParam intercom_secret_key string  intercom_secret_key
// @param kubernetes_rabbitmq_uri_sailor string kubernetes_rabbitmq_uri_sailor
// @param kubernetes_slugs_base_url string kubernetes_slugs_base_url
// @optionalParam lookout_prefetch_count string 10 lookout_prefetch_count
// @optionalParam steward_attachments_lifetime_days number 30 time to live for steward attachments
// @param mandrill_api_key string mandrill_api_key
// @param message_crypto_iv string message_crypto_iv
// @param message_crypto_password string message_crypto_password
// @param mongo_uri string mongo_uri
// @param petstore_api_host string petstore_api_host
// @param predefined_users string predefined_users
// @optionalParam quota_service_mongo_uri string  quota_service_mongo_uri
// @param rabbitmq_stats_login string rabbitmq_stats_login
// @param rabbitmq_stats_pass string rabbitmq_stats_pass
// @param rabbitmq_stats_uri string rabbitmq_stats_uri
// @param rabbitmq_uri_boatswains string rabbitmq_uri_boatswains
// @param rabbitmq_uri_sailor string rabbitmq_uri_sailor
// @param rabbitmq_virtual_host string rabbitmq_virtual_host
// @optionalParam rabbitmq_max_messages_per_queue number 75000 rabbitmq_max_messages_per_queue
// @optionalParam rabbitmq_max_messages_mbytes_per_queue number 200 rabbitmq_max_messages_mbytes_per_queue
// @optionalParam rabbitmq_extend_policies string {} rabbitmq_extend_policies
// @param service_account_username string service_account_username
// @param service_account_password string service_account_password
// @param session_mongo_uri string session_mongo_uri
// @param slug_base_url string slug_base_url
// @optionalParam status_page_id string  status_page_id
// @param steward_storage_uri string steward_storage_uri
// @optionalParam suspended_task_max_messages_count number 50 suspended_task_max_messages_count
// @optionalParam suspend_watch_kubernetes_max_events number 5 suspend_watch_kubernetes_max_events
// @param team_name string team_name
// @param tenant_code string tenant_code
// @param tenant_domain string tenant_domain
// @param tenant_api_domain string tenant_api_domain
// @param tenant_webhooks_domain string tenant_webhooks_domain
// @param tenant_name string tenant_name
// @param user_amqp_crypto_password string user_amqp_crypto_password
// @param user_api_crypto_password string user_api_crypto_password
// @param webhooks_base_uri string webhooks_base_uri
// @param tenant_admin_email string tenant_admin_email
// @param tenant_admin_password string tenant_admin_password
// @optionalParam log_level string warn log_level
// @param wiper_login string wiper_login
// @param wiper_password string wiper_password
// @optionalParam push_gateway_uri string  push_gateway_uri
// @param iron_bank_clickhouse_uri string iron_bank_clickhouse_uri
// @optionalParam iron_bank_clickhouse_no_replica string  iron_bank_clickhouse_no_replica
// @optionalParam kubernetes_ordinary_label_value string  kubernetes_ordinary_label_value
// @optionalParam kubernetes_long_running_label_value string  kubernetes_long_running_label_value
// @optionalParam frontend_no_external_resources string  frontend_no_external_resources
// @param tenant_operator_login string Service account login for handmaiden service
// @param tenant_operator_password string Service account password for handmaiden service
// @optionalParam server_port_range string    port range for bloody-gate
// @optionalParam server_private_network string   vpn network for bloody-gate
// @optionalParam certificate_subject string   subject for bloody-gate server CA
// @optionalParam agent_vpn_entrypoint string    ip/domain for local agent
// @optionalParam maester_jwt_secret string  maester_jwt_secret
// @optionalParam maester_enabled string false is maester service enabled
// @optionalParam maester_redis_uri string  maester_redis_uri
// @optionalParam maester_objects_ttl_in_seconds string 86400 maester_objects_ttl_in_seconds
// @optionalParam maester_object_storage_size_threshold string 1048576 maester_object_storage_size_threshold

local k = import 'k.libsonnet';

local accounts_password = import 'param://accounts_password';
local admiral_service_account_username = import 'param://admiral_service_account_username';
local admiral_service_account_password = import 'param://admiral_service_account_password';
local allow_empty_contract_after_the_last_user_removing = import 'param://allow_empty_contract_after_the_last_user_removing';
local amqp_uri = import 'param://amqp_uri';
local api_uri = import 'param://external_api_uri';
local api_service = 'api-service/9000';
local appdirect_marketplace_url = import 'param://appdirect_marketplace_url';
local appdirect_subscription_events_uri = import 'param://appdirect_subscription_events_uri';
local apidocs_service = 'api-docs-service/8000';
local apprunner_image = import 'param://apprunner_image';
local bran_clickhouse_uri = import 'param://bran_clickhouse_uri';
local bran_enabled = import 'param://bran_enabled';
local bran_read_uri = 'http://bran-read-service.platform.svc.cluster.local:5961';
local bran_prefetch_count = import 'param://bran_prefetch_count';
local certificate_store_encryption_password = import 'param://certificate_store_encryption_password';
local company_name = import 'param://company_name';
local component_cpu = import 'param://component_cpu';
local component_cpu_limit = import 'param://component_cpu_limit';
local component_mem_default = import 'param://component_mem_default';
local component_mem_default_limit = import 'param://component_mem_default_limit';
local component_mem_java = import 'param://component_mem_java';
local component_mem_java_limit = import 'param://component_mem_java_limit';
local cookie_max_age = import 'param://cookie_max_age';
local debug_data_size_limit_mb = import 'param://debug_data_size_limit_mb';
local default_per_contract_quota = import 'param://default_per_contract_quota';
local elastic_search_uri = import 'param://elastic_search_uri';
local enforce_quota = import 'param://enforce_quota';
local environment = import 'param://environment';
local env_password = import 'param://env_password';
local external_api_uri = import 'param://external_api_uri';
local external_app_uri = import 'param://external_app_uri';
local external_gateway_uri = import 'param://external_gateway_uri';
local external_steward_uri = 'http://steward-service.platform.svc.cluster.local:8200';
local frontend_no_external_resources = import 'param://frontend_no_external_resources';
local frontend_service = 'frontend-service/8000';
local frontend_service_account_username = import 'param://frontend_service_account_username';
local frontend_service_account_password = import 'param://frontend_service_account_password';
local gelf_address = import 'param://gelf_address';
local gelf_host = import 'param://gelf_host';
local gelf_port = import 'param://gelf_port';
local gelf_protocol = import 'param://gelf_protocol';
local gendry_service_accounts = import 'param://gendry_service_accounts';
local git_receiver_host = import 'param://git_receiver_host';
local limited_workspace_flow_ttl_in_minutes = import 'param://limited_workspace_flow_ttl_in_minutes';
local hooks_data_password = import 'param://hooks_data_password';
local ignore_container_errors = import 'param://ignore_container_errors';
local intercom_access_token = import 'param://intercom_access_token';
local intercom_app_id = import 'param://intercom_app_id';
local intercom_secret_key = import 'param://intercom_secret_key';
local kubernetes_rabbitmq_uri_sailor = import 'param://kubernetes_rabbitmq_uri_sailor';
local kubernetes_slugs_base_url = import 'param://kubernetes_slugs_base_url';
local lookout_prefetch_count = import 'param://lookout_prefetch_count';
local mandrill_api_key = import 'param://mandrill_api_key';
local maester_enabled = import 'param://maester_enabled';
local maester_jwt_secret = import 'param://maester_jwt_secret';
local maester_uri = 'http://maester-service.platform.svc.cluster.local:3002';
local maester_redis_uri = 'redis://maester-redis-service.platform.svc.cluster.local:6379';
local maester_objects_ttl_in_seconds = import 'param://maester_objects_ttl_in_seconds';
local maester_object_storage_size_threshold = import 'param://maester_object_storage_size_threshold';
local message_crypto_iv = import 'param://message_crypto_iv';
local message_crypto_password = import 'param://message_crypto_password';
local mongo_uri = import 'param://mongo_uri';
local petstore_api_host = import 'param://petstore_api_host';
local predefined_users = import 'param://predefined_users';
local push_gateway_uri = import 'param://push_gateway_uri';
local quota_service_uri = 'http://quota-service-service.platform.svc.cluster.local:3002';
local quota_service_mongo_uri = import 'param://quota_service_mongo_uri';
local quotas_uri = 'http://gold-dragon-coin-service.platform.svc.cluster.local:9000';
local rabbitmq_stats_login = import 'param://rabbitmq_stats_login';
local rabbitmq_stats_pass = import 'param://rabbitmq_stats_pass';
local rabbitmq_stats_uri = import 'param://rabbitmq_stats_uri';
local rabbitmq_uri_boatswains = import 'param://rabbitmq_uri_boatswains';
local rabbitmq_uri_sailor = import 'param://rabbitmq_uri_sailor';
local rabbitmq_virtual_host = import 'param://rabbitmq_virtual_host';
local rabbitmq_max_messages_per_queue = import 'param://rabbitmq_max_messages_per_queue';
local rabbitmq_max_messages_mbytes_per_queue = import 'param://rabbitmq_max_messages_mbytes_per_queue';
local rabbitmq_extend_policies = import 'param://rabbitmq_extend_policies';
local raven_uri = 'http://raven-service.platform.svc.cluster.local:8070';
local service_account_username = import 'param://service_account_username';
local service_account_password = import 'param://service_account_password';
local session_mongo_uri = import 'param://session_mongo_uri';
local slug_base_url = import 'param://slug_base_url';
local status_page_id = import 'param://status_page_id';
local steward_storage_uri = import 'param://steward_storage_uri';
local steward_uri = 'http://steward-service.platform.svc.cluster.local:8200';
local steward_attachments_lifetime_days = import 'param://steward_attachments_lifetime_days';
local suspended_task_max_messages_count = import 'param://suspended_task_max_messages_count';
local suspend_watch_kubernetes_max_events = import 'param://suspend_watch_kubernetes_max_events';
local team_name = import 'param://team_name';
local tenant_code = import 'param://tenant_code';
local tenant_domain = import 'param://tenant_domain';
local tenant_api_domain = import 'param://tenant_api_domain';
local tenant_webhooks_domain = import 'param://tenant_webhooks_domain';
local tenant_name = import 'param://tenant_name';
local user_amqp_crypto_password = import 'param://user_amqp_crypto_password';
local user_api_crypto_password = import 'param://user_api_crypto_password';
local webhooks_base_uri = import 'param://webhooks_base_uri';
local webhooks_service = 'webhooks-service/5000';
local tenant_admin_email = import 'param://tenant_admin_email';
local tenant_admin_password = import 'param://tenant_admin_password';
local log_level = import 'param://log_level';
local wiper_login = import 'param://wiper_login';
local wiper_password = import 'param://wiper_password';
local appdirect_login = import 'param://appdirect_login';
local appdirect_password = import 'param://appdirect_password';
local tenant_operator_login = import 'param://tenant_operator_login';
local tenant_operator_password = import 'param://tenant_operator_password';
local iron_bank_clickhouse_uri = import 'param://iron_bank_clickhouse_uri';
local iron_bank_clickhouse_no_replica = import 'param://iron_bank_clickhouse_no_replica';
local iron_bank_uri = 'http://iron-bank-service.platform.svc.cluster.local:3000';
local kubernetes_ordinary_label_value = import 'param://kubernetes_ordinary_label_value';
local kubernetes_long_running_label_value = import 'param://kubernetes_long_running_label_value';
local server_port_range = import 'param://server_port_range';
local server_private_network = import 'param://server_private_network';
local certificate_subject = import 'param://certificate_subject';
local agent_vpn_entrypoint = import 'param://agent_vpn_entrypoint';

local checkMaesterKey = if maester_enabled == 'true' && maester_jwt_secret == '' then
  error 'maester_jwt_secret is required';

[
  k.core.v1.namespace.new('platform').withLabels({name: 'platform'}),
  k.core.v1.namespace.new('tasks').withLabels({name: 'tasks'}),
  k.core.v1.namespace.new('monitoring').withLabels({name: 'monitoring'}),
  {
    apiVersion: 'v1',
    stringData: {
      ACCOUNTS_PASSWORD: std.toString(accounts_password),
      ADMIRAL_SERVICE_ACCOUNT_USERNAME: admiral_service_account_username,
      ADMIRAL_SERVICE_ACCOUNT_PASSWORD: admiral_service_account_password,
      [if agent_vpn_entrypoint != '' then 'AGENT_VPN_ENTRYPOINT']: agent_vpn_entrypoint,
      ALLOW_EMPTY_CONTRACT_AFTER_THE_LAST_USER_REMOVING: std.toString(if allow_empty_contract_after_the_last_user_removing == "true" then "true" else ""),
      AMQP_URI: std.toString(amqp_uri),
      API_URI: std.toString(api_uri),
      API_SERVICE: std.toString(api_service),
      APPDIRECT_MARKETPLACE_URL: std.toString(appdirect_marketplace_url),
      APPDIRECT_SUBSCRIPTION_EVENTS_URI: std.toString(appdirect_subscription_events_uri),
      APIDOCS_SERVICE: std.toString(apidocs_service),
      APPDIRECT_SERVICE_ACCOUNT_USERNAME: std.toString(appdirect_login),
      APPDIRECT_SERVICE_ACCOUNT_PASSWORD: std.toString(appdirect_password),
      APPRUNNER_IMAGE: std.toString(apprunner_image),
      [if bran_clickhouse_uri != '' then 'BRAN_CLICKHOUSE_URI']: std.toString(bran_clickhouse_uri),
      [if bran_enabled != '' then 'BRAN_ENABLED']: std.toString(bran_enabled),
      [if bran_read_uri != '' then 'BRAN_READ_URI']: std.toString(bran_read_uri),
      BRAN_PREFETCH_COUNT: std.toString(bran_prefetch_count),
      IRON_BANK_CLICKHOUSE_URI: std.toString(iron_bank_clickhouse_uri),
      IRON_BANK_CLICKHOUSE_NO_REPLICA: std.toString(iron_bank_clickhouse_no_replica),
      [if iron_bank_uri != '' then 'IRON_BANK_URI']: std.toString(iron_bank_uri),
      CERTIFICATE_STORE_ENCRYPTION_PASSWORD: std.toString(certificate_store_encryption_password),
      COMPANY_NAME: std.toString(company_name),
      COMPONENT_CPU: std.toString(component_cpu),
      COMPONENT_CPU_LIMIT: std.toString(component_cpu_limit),
      COMPONENT_MEM_DEFAULT: std.toString(component_mem_default),
      COMPONENT_MEM_DEFAULT_LIMIT: std.toString(component_mem_default_limit),
      COMPONENT_MEM_JAVA: std.toString(component_mem_java),
      COMPONENT_MEM_JAVA_LIMIT: std.toString(component_mem_java_limit),
      COOKIE_MAX_AGE: std.toString(cookie_max_age),
      DEBUG_DATA_SIZE_LIMIT_MB: std.toString(debug_data_size_limit_mb),
      DEFAULT_DRIVER_BACKEND: 'kubernetes',
      DEFAULT_PER_CONTRACT_QUOTA: std.toString(default_per_contract_quota),
      ELASTIC_SEARCH_URI: std.toString(elastic_search_uri),
      ENFORCE_QUOTA: std.toString(enforce_quota),
      ENVIRONMENT: std.toString(environment),
      ENV_PASSWORD: std.toString(env_password),
      EXTERNAL_API_URI: std.toString(external_api_uri),
      EXTERNAL_APP_URI: std.toString(external_app_uri),
      EXTERNAL_GATEWAY_URI: std.toString(external_gateway_uri),
      EXTERNAL_STEWARD_URI: std.toString(external_steward_uri),
      FRONTEND_SERVICE: std.toString(frontend_service),
      FRONTEND_SERVICE_ACCOUNT_USERNAME: std.toString(frontend_service_account_username),
      FRONTEND_SERVICE_ACCOUNT_PASSWORD: std.toString(frontend_service_account_password),
      [if frontend_no_external_resources != '' then 'FRONTEND_NO_EXTERNAL_RESOURCES']: std.toString(frontend_no_external_resources),
      GELF_ADDRESS: std.toString(gelf_address),
      GELF_HOST: std.toString(gelf_host),
      GELF_PORT: std.toString(gelf_port),
      GELF_PROTOCOL: std.toString(gelf_protocol),
      GENDRY_SERVICE_ACCOUNTS: std.toString(gendry_service_accounts),
      GIT_RECEIVER_HOST: std.toString(git_receiver_host),
      LIMITED_WORKSPACE_FLOW_TTL_IN_MINUTES: std.toString(limited_workspace_flow_ttl_in_minutes),
      HOOKS_DATA_PASSWORD: std.toString(hooks_data_password),
      [if ignore_container_errors != '' then 'IGNORE_CONTAINER_ERRORS']: std.toString(ignore_container_errors),
      INTERCOM_ACCESS_TOKEN: std.toString(intercom_access_token),
      INTERCOM_APP_ID: std.toString(intercom_app_id),
      INTERCOM_SECRET_KEY: std.toString(intercom_secret_key),
      KUBERNETES_RABBITMQ_URI_SAILOR: std.toString(kubernetes_rabbitmq_uri_sailor),
      KUBERNETES_SLUGS_BASE_URL: std.toString(kubernetes_slugs_base_url),
      [if kubernetes_ordinary_label_value != '' then 'KUBERNETES_ORDINARY_LABEL_VALUE']: std.toString(kubernetes_ordinary_label_value),
      [if kubernetes_long_running_label_value != '' then 'KUBERNETES_LONG_RUNNING_LABEL_VALUE']: std.toString(kubernetes_long_running_label_value),
      LOOKOUT_PREFETCH_COUNT: std.toString(lookout_prefetch_count),
      MANDRILL_API_KEY: std.toString(mandrill_api_key),
      MARATHON_URI: 'deprecated',
      MESSAGE_CRYPTO_IV: std.toString(message_crypto_iv),
      MESSAGE_CRYPTO_PASSWORD: std.toString(message_crypto_password),
      MONGO_URI: std.toString(mongo_uri),
      NODE_ENV: 'production',
      PETSTORE_API_HOST: std.toString(petstore_api_host),
      PREDEFINED_USERS: std.toString(predefined_users),
      PUSH_GATEWAY_URI: std.toString(push_gateway_uri),
      [if quota_service_uri != '' then 'QUOTA_SERVICE_URI']: std.toString(quota_service_uri),
      [if quota_service_mongo_uri != '' then 'QUOTA_SERVICE_MONGO_URI']: std.toString(quota_service_mongo_uri),
      QUOTAS_URI: std.toString(quotas_uri),
      RABBITMQ_STATS_LOGIN: std.toString(rabbitmq_stats_login),
      RABBITMQ_STATS_PASS: std.toString(rabbitmq_stats_pass),
      RABBITMQ_STATS_URI: std.toString(rabbitmq_stats_uri),
      RABBITMQ_URI_BOATSWAINS: std.toString(rabbitmq_uri_boatswains),
      RABBITMQ_URI_SAILOR: std.toString(rabbitmq_uri_sailor),
      RABBITMQ_VIRTUAL_HOST: std.toString(rabbitmq_virtual_host),
      RABBITMQ_MAX_MESSAGES_PER_QUEUE: std.toString(rabbitmq_max_messages_per_queue),
      RABBITMQ_MAX_MESSAGES_MBYTES_PER_QUEUE: std.toString(rabbitmq_max_messages_mbytes_per_queue),
      RABBITMQ_EXTEND_POLICIES: std.toString(rabbitmq_extend_policies),
      RAVEN_URI: std.toString(raven_uri),
      SERVICE_ACCOUNT_USERNAME: std.toString(service_account_username),
      SERVICE_ACCOUNT_PASSWORD: std.toString(service_account_password),
      SESSION_MONGO_URI: std.toString(session_mongo_uri),
      SLUG_BASE_URL: std.toString(slug_base_url),
      STEWARD_STORAGE_URI: std.toString(steward_storage_uri),
      STEWARD_ATTACHMENTS_LIFETIME_DAYS: std.toString(steward_attachments_lifetime_days),
      STATUS_PAGE_ID: std.toString(status_page_id),
      STEWARD_URI: std.toString(steward_uri),
      SUSPENDED_TASK_MAX_MESSAGES_COUNT: std.toString(suspended_task_max_messages_count),
      SUSPEND_WATCH_KUBERNETES_MAX_EVENTS: std.toString(suspend_watch_kubernetes_max_events),
      [if server_port_range != '' then 'SERVER_PORT_RANGE']: server_port_range,
      [if server_private_network != '' then 'SERVER_PRIVATE_NETWORK']: server_private_network,
      [if certificate_subject != '' then 'CERTIFICATE_SUBJECT']: certificate_subject,
      TEAM_NAME: std.toString(team_name),
      TENANT_CODE: std.toString(tenant_code),
      TENANT_DOMAIN: std.toString(tenant_domain),
      TENANT_API_DOMAIN: std.toString(tenant_api_domain),
      TENANT_WEBHOOKS_DOMAIN: std.toString(tenant_webhooks_domain),
      TENANT_NAME: std.toString(tenant_name),
      TENANT_OPERATOR_SERVICE_ACCOUNT_USERNAME: std.toString(tenant_operator_login),
      TENANT_OPERATOR_SERVICE_ACCOUNT_PASSWORD: std.toString(tenant_operator_password),
      USER_AMQP_CRYPTO_PASSWORD: std.toString(user_amqp_crypto_password),
      USER_API_CRYPTO_PASSWORD: std.toString(user_api_crypto_password),
      WEBHOOKS_BASE_URI: std.toString(webhooks_base_uri),
      WEBHOOKS_SERVICE: std.toString(webhooks_service),
      WIPER_SERVICE_ACCOUNT_USERNAME: std.toString(wiper_login),
      WIPER_SERVICE_ACCOUNT_PASSWORD: std.toString(wiper_password),
      TENANT_ADMIN_EMAIL: std.toString(tenant_admin_email),
      TENANT_ADMIN_PASSWORD: std.toString(tenant_admin_password),
      LOG_LEVEL: std.toString(log_level)
    } + (
      if std.toString(maester_enabled) == 'true' then {
        MAESTER_URI: std.toString(maester_uri),
        MAESTER_JWT_SECRET: std.toString(maester_jwt_secret),
        MAESTER_REDIS_URI: std.toString(maester_redis_uri),
        MAESTER_OBJECTS_TTL_IN_SECONDS: std.toString(maester_objects_ttl_in_seconds),
        MAESTER_OBJECT_STORAGE_SIZE_THRESHOLD: std.toString(maester_object_storage_size_threshold)
      } else {}
    ),
    kind: 'Secret',
    metadata: {
      name: 'elasticio',
      namespace: 'platform',
    },
  }
]
