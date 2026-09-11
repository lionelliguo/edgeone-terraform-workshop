# EdgeOne Terraform Workshop Lab Guide

## 目录式 Lab 流程

每个 Lab 都有独立目录和递进式 Terraform 代码。请从对应目录执行 Terraform，避免在错误目录执行。

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

## 建议顺序

1. `lab-01-provider-init`：Provider 初始化
2. `lab-02-query-plans`：查询套餐
3. `lab-03-create-site`：创建站点
4. `lab-04-ownership-verify`：所有权验证
5. `lab-05-domain-management`：域名管理
6. `lab-06-cname-setup`：CNAME 设置
7. `lab-07-ssl-certificate`：SSL 证书
8. `lab-08-rule-engine`：规则引擎
9. `lab-09-security-policy`：安全策略
10. `lab-10-bot-intelligence`：智能Bot
11. `lab-11-web-security-template`：Web 安全模板
12. `lab-12-version-management`：版本管理
13. `lab-13-update-version`：更新版本
14. `lab-14-purge-cache`：清除缓存
15. `lab-15-prefetch-urls`：预取 URLs
16. `lab-16-resource-cleanup`：资源清理

## 资源与规则对照表

| Lab 目录 | 创建或管理的资源 | 资源或规则作用 |
| --- | --- | --- |
| `lab-01-provider-init` | `terraform_data.lab_sequence_guard`、local backend、TencentCloud Provider 配置 | 初始化 Terraform 执行环境，写入顺序保护 Lab ID；不创建云资源 |
| `lab-02-query-plans` | `data.tencentcloud_teo_zone_available_plans.available`、`terraform_data.lab_sequence_guard` | 只读查询当前账号可用 EdgeOne 套餐，确认后续创建 Site 所需的 `plan_id`；不创建云资源 |
| `lab-03-create-site` | `tencentcloud_teo_zone.zone` | 创建 EdgeOne Site/Zone，使用 `partial` 接入模式，并配置 `zone_name`、`alias_zone_name`、`area` 和 `plan_id` |
| `lab-04-ownership-verify` | `tencentcloud_teo_ownership_verify.zone`、可选 `tencentcloud_dnspod_record.ownership` | 发起域名所有权验证；自动 DNSPod 模式下创建验证记录，手工 DNS 模式下输出验证信息 |
| `lab-05-domain-management` | `tencentcloud_teo_acceleration_domain.www` | 创建 `www` 业务加速域名，配置源站、源站类型、Host Header、回源端口、回源协议和在线状态 |
| `lab-06-cname-setup` | 可选 `tencentcloud_dnspod_record.www_cname`、`tencentcloud_teo_acceleration_domain.www` | 自动 DNSPod 模式下创建业务 CNAME；手工 DNS 模式下输出 EdgeOne CNAME 供外部 DNS 配置 |
| `lab-07-ssl-certificate` | `tencentcloud_teo_certificate_config.www` | 为 `www` 加速域名配置 HTTPS 证书，支持 EdgeOne 免费证书或已有 SSL 证书 |
| `lab-08-rule-engine` | `tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache` | 创建 Rule Engine 规则 `workshop-www-https-cache`，包含 HTTPS 强制跳转、静态资源 30 天缓存和动态页面 no-cache |
| `lab-09-security-policy` | `tencentcloud_teo_security_policy_config.zone_default` | 在 `ZoneDefaultPolicy` 中新增 Custom Rule `monitor-curl-on-login`，匹配 `/login` + `curl` 请求并执行 `Monitor` |
| `lab-10-bot-intelligence` | `tencentcloud_teo_security_policy_config.zone_default` | 启用 Bot Management 和智能Bot；新增 Bot Custom Rule `bot-monitor-api-curl`，匹配 `/api` + `curl` 请求并执行 `Monitor`；High Risk/Likely Bot 使用 `Monitor`，Verified Bot/Human 使用 `Allow` |
| `lab-11-web-security-template` | `tencentcloud_teo_web_security_template.workshop`、`tencentcloud_teo_bind_security_template.www` | 创建 Web 安全模板 `workshop_www_security` 并绑定到 `www`；模板包含 `monitor-curl-on-login`、`monitor-api-curl`、`bot-monitor-api-curl`、`login-single-ip-rate-limit` 和 `health-check-skip-security-modules` |
| `lab-12-version-management` | `tencentcloud_teo_config_group_version.workshop_l7`、`tencentcloud_teo_deploy_config_group_version.workshop_l7_*` | 启用 L7 版本管理，把当前 L7 配置打包为配置组版本并发布到 Staging 和 Production；版本内容包含 `workshop-www-https-cache` |
| `lab-13-update-version` | `tencentcloud_teo_config_group_version.workshop_l7_update`、`tencentcloud_teo_deploy_config_group_version.workshop_l7_update_*` | 通过版本管理新增 Rule Engine 规则 `workshop-version-canary-no-cache`，匹配 `/version-canary/*` 并设置 no-cache，然后发布到 Staging 和 Production |
| `lab-14-purge-cache` | `tencentcloud_teo_purge_task.www_home` | 提交 URL 刷新任务，目标为 `https://www.<zone_name>/`，清除边缘节点中的已有缓存 |
| `lab-15-prefetch-urls` | `tencentcloud_teo_prefetch_task_operation.www_home` | 提交 URL 预热任务，目标为 `https://www.<zone_name>/`，让 EdgeOne 节点提前从源站拉取内容 |
| `lab-16-resource-cleanup` | 当前共享 state 中已创建或管理的 workshop 资源 | destroy-only 清理 Lab，可在任意已完成 Lab 之后执行，清理 Site、加速域名、证书、规则、安全策略、模板、版本、缓存任务、DNSPod 可选记录和顺序保护记录 |

## 重要说明

- 每个 Lab 目录下都有自己的 `terraform/` 子目录。
- `labs/lab-common/` 保存所有 Lab 共用的 `terraform.tfvars` 和 `credentials.auto.tfvars`。
- 每个 Lab 通过 `-var-file=../../lab-common/...` 显式读取公共配置，因此只需要配置一次。
- 每个 Lab 目录通过 local backend 共用 `shared/edgeone-workshop.tfstate`，因此可以按目录顺序连续执行。
- 切换到下一个 Lab 目录后需要重新执行 `terraform init`，让 Terraform 初始化该目录的 backend 和 provider。
- 使用 Terraform 原生命令执行 `plan`、`apply` 和 `destroy`。顺序检查由每个 Lab 的 `sequence_guard.tf` 完成。
- 部分早期 Lab 包含 `removed.tf`，用于在误回到早期 Lab 时避免 Terraform 直接规划销毁后续 Lab 资源；这些配置只从 Terraform state 遗忘对象，不会销毁云上资源。倒退执行仍会被 `sequence_guard.tf` 拒绝；如果在错误提示前看到 “will no longer be managed by Terraform, but will not be destroyed”，这是 Terraform 在执行顺序检查前根据 state/config 差异打印的保护性提示，不要继续 apply，应按错误提示从 Lab 01 重新开始或执行 Lab 16 清理。
- 不要提交真实凭证、`terraform.tfvars`、`terraform.tfstate` 或 `.terraform/`。

## 输出对照表

| Lab 目录 | 目标 | 最终输出 |
| --- | --- | --- |
| `lab-01-provider-init` | Provider 初始化 | `lab_id`、`lab_success`、`created_resource_names`、`current_execution`、`ownership_verification`、`zone_id`、`zone_name`、`zone_status`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-02-query-plans` | 查询套餐 | `lab_id`、`available_edgeone_plans`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-03-create-site` | 创建站点 | `lab_id`、`zone_id`、`zone_name`、`zone_status`、`ownership_verification`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-04-ownership-verify` | 所有权验证 | `lab_id`、`zone_id`、`ownership_verify_status`、`ownership_verification`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-05-domain-management` | 域名管理 | `lab_id`、`zone_id`、`acceleration_domain`、`edgeone_cname`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-06-cname-setup` | CNAME 设置 | `lab_id`、`acceleration_domain`、`edgeone_cname`、`dnspod_cname_record_id`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-07-ssl-certificate` | SSL 证书 | `lab_id`、`https_host`、`certificate_mode`、`certificate_config_id`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-08-rule-engine` | 规则引擎 | `lab_id`、`acceleration_domain`、`l7_rule_id`、`l7_rule_name`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-09-security-policy` | 安全策略 | `lab_id`、`security_policy_enabled`、`security_policy_id`、`security_policy_entity`、`lab_success`、`security_custom_rule_names`、`new_rule_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-10-bot-intelligence` | 智能Bot | `lab_id`、`bot_intelligence_enabled`、`security_policy_id`、`bot_high_risk_action`、`bot_custom_rule_name`、`lab_success`、`security_custom_rule_names`、`bot_custom_rule_names`、`new_rule_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-11-web-security-template` | Web 安全模板 | `lab_id`、`web_security_template_enabled`、`web_security_template_id`、`web_security_template_name`、`web_security_template_bind_status`、`security_template_domain`、`lab_success`、`security_custom_rule_names`、`bot_custom_rule_names`、`rate_limiting_rule_names`、`exception_rule_names`、`new_rule_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-12-version-management` | 版本管理 | `lab_id`、`version_management_enabled`、`version_deploy_enabled`、`version_config_type`、`version_control_work_mode`、`version_env_id`、`discovered_version_env_id`、`discovered_production_env_id`、`discovered_staging_env_id`、`version_deploy_env_ids`、`version_group_id`、`discovered_version_group_id`、`version_resource_status`、`config_group_version_id`、`config_group_version_number`、`deploy_record_id`、`deploy_status`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-13-update-version` | 更新版本 | `lab_id`、`version_management_enabled`、`version_deploy_enabled`、`version_config_type`、`version_control_work_mode`、`version_env_id`、`discovered_version_env_id`、`discovered_production_env_id`、`discovered_staging_env_id`、`version_deploy_env_ids`、`version_group_id`、`discovered_version_group_id`、`version_resource_status`、`updated_version_resource_status`、`config_group_version_id`、`config_group_version_number`、`deploy_record_id`、`deploy_status`、`updated_config_group_version_id`、`updated_config_group_version_number`、`updated_rule_engine_rule_name`、`updated_deploy_record_id`、`updated_deploy_status`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-14-purge-cache` | 清除缓存 | `lab_id`、`purge_type`、`purge_job_id`、`purge_targets`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-15-prefetch-urls` | 预取 URLs | `lab_id`、`prefetch_job_id`、`prefetch_targets`、`prefetch_mode`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result` |
| `lab-16-resource-cleanup` | 资源清理 | `lab_id`、`lab_success`、`cleanup_resource_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`；执行 destroy 后以 state 清空为准 |

注意：Lab 16 是 destroy-only 清理 Lab，可以在任意已完成 Lab 之后执行，用于清理此前已经创建并写入共享 state 的资源。不要执行普通 `terraform apply`；请使用 Lab16 README 中带 `cleanup_confirm_destroy=true` 的 `terraform plan -destroy` 和 `terraform destroy` 命令。

## 公共配置初始化

```bash
cd labs/lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

编辑：

```text
terraform.tfvars
credentials.auto.tfvars
```

## Lab 执行示例

```bash
cd ../lab-03-create-site/terraform
terraform init
terraform validate
terraform plan -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```


## 顺序保护

每个 Lab 会把 `lab_id` 写入共享 state。从 Lab 02 开始，Terraform 会检查共享 state 是否由上一个 Lab 产生。如果没有按顺序执行，`terraform plan` 或 `terraform apply` 会提示从 Lab 01 开始并按顺序完成 workshop。

从 Lab 12 启用 Version Management 后，Lab 01 到 Lab 11 会拒绝继续执行，避免在 EdgeOne 站点进入 `version_control` 模式后再次修改早期即时生效配置。如果需要重新开始，请先执行 Lab 16 清理资源和共享 state，然后从 Lab 01 重新开始。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
