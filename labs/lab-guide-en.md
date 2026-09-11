# EdgeOne Terraform Workshop Lab Guide

## Directory-Based Lab Flow

Each Lab has its own directory and staged Terraform code. Run Terraform from the matching Lab directory to avoid applying the wrong stage.

```text
labs/
  lab-common/
  lab-01-provider-init/
  lab-02-query-plans/
  lab-03-create-site/
  lab-04-ownership-verify/
  lab-05-domain-management/
  lab-06-cname-setup/
  lab-07-ssl-certificate/
  lab-08-rule-engine/
  lab-09-security-policy/
  lab-10-bot-intelligence/
  lab-11-web-security-template/
  lab-12-version-management/
  lab-13-update-version/
  lab-14-purge-cache/
  lab-15-prefetch-urls/
  lab-16-resource-cleanup/
```

## Recommended Order

1. `lab-01-provider-init`
2. `lab-02-query-plans`
3. `lab-03-create-site`
4. `lab-04-ownership-verify`
5. `lab-05-domain-management`
6. `lab-06-cname-setup`
7. `lab-07-ssl-certificate`
8. `lab-08-rule-engine`
9. `lab-09-security-policy`
10. `lab-10-bot-intelligence`
11. `lab-11-web-security-template`
12. `lab-12-version-management`
13. `lab-13-update-version`
14. `lab-14-purge-cache`
15. `lab-15-prefetch-urls`
16. `lab-16-resource-cleanup`

## Resource and Rule Matrix

| Lab Directory | Resources Created or Managed | Purpose |
| --- | --- | --- |
| `lab-01-provider-init` | `terraform_data.lab_sequence_guard`, local backend, TencentCloud Provider configuration | Initializes the Terraform execution environment and writes the sequence-protection Lab ID; no cloud resources are created |
| `lab-02-query-plans` | `data.tencentcloud_teo_zone_available_plans.available`, `terraform_data.lab_sequence_guard` | Performs a read-only query for EdgeOne plans available to the current account and confirms the `plan_id`; no cloud resources are created |
| `lab-03-create-site` | `tencentcloud_teo_zone.zone` | Creates the EdgeOne Site/Zone in `partial` onboarding mode with `zone_name`, `alias_zone_name`, `area`, and `plan_id` |
| `lab-04-ownership-verify` | `tencentcloud_teo_ownership_verify.zone`, optional `tencentcloud_dnspod_record.ownership` | Starts domain ownership verification; automated DNSPod mode creates the verification record, while manual DNS mode outputs the required verification details |
| `lab-05-domain-management` | `tencentcloud_teo_acceleration_domain.www` | Creates the `www` business acceleration domain and configures origin, origin type, Host Header, origin ports, origin protocol, and online status |
| `lab-06-cname-setup` | Optional `tencentcloud_dnspod_record.www_cname`, `tencentcloud_teo_acceleration_domain.www` | Creates the business CNAME in automated DNSPod mode, or outputs the EdgeOne CNAME for manual DNS configuration |
| `lab-07-ssl-certificate` | `tencentcloud_teo_certificate_config.www` | Configures HTTPS certificate settings for the `www` acceleration domain, using either an EdgeOne free certificate or an existing SSL certificate |
| `lab-08-rule-engine` | `tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache` | Creates Rule Engine rule `workshop-www-https-cache` with HTTPS redirect, 30-day static asset caching, and dynamic no-cache behavior |
| `lab-09-security-policy` | `tencentcloud_teo_security_policy_config.zone_default` | Adds Custom Rule `monitor-curl-on-login` to `ZoneDefaultPolicy`, matching `/login` + `curl` requests and applying `Monitor` |
| `lab-10-bot-intelligence` | `tencentcloud_teo_security_policy_config.zone_default` | Enables Bot Management and Bot Intelligence; adds Bot Custom Rule `bot-monitor-api-curl` for `/api` + `curl` requests with `Monitor`; High Risk/Likely Bot use `Monitor`, Verified Bot/Human use `Allow` |
| `lab-11-web-security-template` | `tencentcloud_teo_web_security_template.workshop`, `tencentcloud_teo_bind_security_template.www` | Creates Web Security Template `workshop_www_security` and binds it to `www`; the template includes `monitor-curl-on-login`, `monitor-api-curl`, `bot-monitor-api-curl`, `login-single-ip-rate-limit`, and `health-check-skip-security-modules` |
| `lab-12-version-management` | `tencentcloud_teo_config_group_version.workshop_l7`, `tencentcloud_teo_deploy_config_group_version.workshop_l7_*` | Enables L7 Version Management, packages the current L7 configuration into a version, and deploys it to Staging and Production; the version includes `workshop-www-https-cache` |
| `lab-13-update-version` | `tencentcloud_teo_config_group_version.workshop_l7_update`, `tencentcloud_teo_deploy_config_group_version.workshop_l7_update_*` | Adds Rule Engine rule `workshop-version-canary-no-cache` through Version Management, matching `/version-canary/*` with no-cache, then deploys to Staging and Production |
| `lab-14-purge-cache` | `tencentcloud_teo_purge_task.www_home` | Submits a URL purge task for `https://www.<zone_name>/` to remove the existing cached object from EdgeOne nodes |
| `lab-15-prefetch-urls` | `tencentcloud_teo_prefetch_task_operation.www_home` | Submits a URL prefetch task for `https://www.<zone_name>/` so EdgeOne nodes pull the object from origin in advance |
| `lab-16-resource-cleanup` | Workshop resources already created or managed in the current shared state | Destroy-only cleanup Lab that can run after any completed Lab and removes Site, acceleration domain, certificate, rules, security policy, template, versions, cache tasks, optional DNSPod records, and sequence guard records |

## Important Notes

- Each Lab directory has its own `terraform/` subdirectory.
- `labs/lab-common/` stores `terraform.tfvars` and `credentials.auto.tfvars` shared by all Labs.
- Each Lab explicitly reads the shared configuration with `-var-file=../../lab-common/...`, so participants only configure it once.
- Each Lab directory uses a local backend pointing to `shared/edgeone-workshop.tfstate`, so the Labs can be run sequentially by changing directories.
- Run `terraform init` again after switching to the next Lab directory so Terraform can initialize that directory's backend and provider.
- Use native Terraform commands for `plan`, `apply`, and `destroy`. Sequence checking is handled by each Lab's `sequence_guard.tf`.
- Some earlier Labs include `removed.tf` so an accidental return to an earlier Lab does not plan direct destruction of resources created by later Labs. These blocks only forget objects from Terraform state and do not destroy cloud resources. Backward execution is still rejected by `sequence_guard.tf`; if “will no longer be managed by Terraform, but will not be destroyed” appears before the sequence error, treat it as Terraform state/config noise before the guard fires. Do not apply; follow the error message and restart from Lab 01 or use Lab 16 cleanup.
- Do not commit real credentials, `terraform.tfvars`, `terraform.tfstate`, or `.terraform/`.

## Output Matrix

| Lab Directory | Goal | Final Outputs |
| --- | --- | --- |
| `lab-01-provider-init` | lab-01-provider-init | `lab_id`, `lab_success`, `created_resource_names`, `current_execution`, `ownership_verification`, `zone_id`, `zone_name`, `zone_status`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-02-query-plans` | lab-02-query-plans | `lab_id`, `available_edgeone_plans`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-03-create-site` | lab-03-create-site | `lab_id`, `zone_id`, `zone_name`, `zone_status`, `ownership_verification`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-04-ownership-verify` | lab-04-ownership-verify | `lab_id`, `zone_id`, `ownership_verify_status`, `ownership_verification`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-05-domain-management` | lab-05-domain-management | `lab_id`, `zone_id`, `acceleration_domain`, `edgeone_cname`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-06-cname-setup` | lab-06-cname-setup | `lab_id`, `acceleration_domain`, `edgeone_cname`, `dnspod_cname_record_id`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-07-ssl-certificate` | lab-07-ssl-certificate | `lab_id`, `https_host`, `certificate_mode`, `certificate_config_id`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-08-rule-engine` | lab-08-rule-engine | `lab_id`, `acceleration_domain`, `l7_rule_id`, `l7_rule_name`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-09-security-policy` | lab-09-security-policy | `lab_id`, `security_policy_enabled`, `security_policy_id`, `security_policy_entity`, `lab_success`, `security_custom_rule_names`, `new_rule_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-10-bot-intelligence` | lab-10-bot-intelligence | `lab_id`, `bot_intelligence_enabled`, `security_policy_id`, `bot_high_risk_action`, `bot_custom_rule_name`, `lab_success`, `security_custom_rule_names`, `bot_custom_rule_names`, `new_rule_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-11-web-security-template` | lab-11-web-security-template | `lab_id`, `web_security_template_enabled`, `web_security_template_id`, `web_security_template_name`, `web_security_template_bind_status`, `security_template_domain`, `lab_success`, `security_custom_rule_names`, `bot_custom_rule_names`, `rate_limiting_rule_names`, `exception_rule_names`, `new_rule_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-12-version-management` | lab-12-version-management | `lab_id`, `version_management_enabled`, `version_deploy_enabled`, `version_config_type`, `version_control_work_mode`, `version_env_id`, `discovered_version_env_id`, `discovered_production_env_id`, `discovered_staging_env_id`, `version_deploy_env_ids`, `version_group_id`, `discovered_version_group_id`, `version_resource_status`, `config_group_version_id`, `config_group_version_number`, `deploy_record_id`, `deploy_status`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-13-update-version` | lab-13-update-version | `lab_id`, `version_management_enabled`, `version_deploy_enabled`, `version_config_type`, `version_control_work_mode`, `version_env_id`, `discovered_version_env_id`, `discovered_production_env_id`, `discovered_staging_env_id`, `version_deploy_env_ids`, `version_group_id`, `discovered_version_group_id`, `version_resource_status`, `updated_version_resource_status`, `config_group_version_id`, `config_group_version_number`, `deploy_record_id`, `deploy_status`, `updated_config_group_version_id`, `updated_config_group_version_number`, `updated_rule_engine_rule_name`, `updated_deploy_record_id`, `updated_deploy_status`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-14-purge-cache` | lab-14-purge-cache | `lab_id`, `purge_type`, `purge_job_id`, `purge_targets`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-15-prefetch-urls` | lab-15-prefetch-urls | `lab_id`, `prefetch_job_id`, `prefetch_targets`, `prefetch_mode`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result` |
| `lab-16-resource-cleanup` | lab-16-resource-cleanup | `lab_id`, `lab_success`, `cleanup_resource_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`; after destroy, success is verified by an empty state |

Note: Lab 16 is a destroy-only cleanup Lab. It can be run after any completed Lab to clean up resources already created and recorded in the shared state. Do not run normal `terraform apply`; use the `terraform plan -destroy` and `terraform destroy` commands with `cleanup_confirm_destroy=true` from the Lab16 README.

## Initialize Common Configuration

```bash
cd labs/lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Edit:

```text
terraform.tfvars
credentials.auto.tfvars
```

## Lab Execution Example

```bash
cd ../lab-03-create-site/terraform
terraform init
terraform validate
terraform plan -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```


## Sequence Protection

Each Lab writes `lab_id` to the shared state. Starting from Lab 02, Terraform checks whether the shared state was produced by the previous Lab. If the Labs are not run in order, `terraform plan` or `terraform apply` prompts the participant to start from Lab 01 and complete the workshop sequentially.

After Lab 12 enables Version Management, Lab 01 through Lab 11 refuse to run. This prevents earlier immediate-effect configuration from being changed after the EdgeOne site enters `version_control` mode. To restart the workshop, run Lab 16 to clean up resources and shared state, then start again from Lab 01.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
