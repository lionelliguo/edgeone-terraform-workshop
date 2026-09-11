# Tencent Cloud EdgeOne Terraform Workshop

3 天培训 Agenda：每天 3 小时，EdgeOne 实操优先版  
版本日期：2026-08-01

## 培训定位

本 agenda 基于当前 `labs/` 目录中的 16 个 Lab 重新整理，每天 3 小时，共 9 小时。本版本节奏更轻，适合半天制培训、线上培训或企业内部连续三天工作坊。

Terraform 部分保持精简，只讲完成实验所需的 Provider、resource、data source、state、plan/apply/destroy、凭证配置、共享 state、顺序保护和 destroy-only 清理。主要时间用于 EdgeOne 接入、域名验证、加速域名、CNAME、SSL 证书、规则引擎、安全策略、智能Bot、Web 安全模板、版本管理、缓存运维和故障排查。

所有 Lab 均以当前 Terraform `outputs.tf` 为准输出 `execution_steps`、`current_execution`、`created_resource_names`、`lab_id`、`lab_success`、`next_lab` 和 `workshop_result`。其中 `execution_steps` 按步骤列出创建、修改或销毁的资源及其具体信息，包括资源名称、关键 ID、规则名称、动作、目标 URL、版本号和部署记录；`workshop_result` 作为最终摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 培训目标

完成培训后，学员应能够：

- 使用 Terraform 初始化 TencentCloud Provider。
- 使用配置文件方式管理培训凭证。
- 使用目录式 Lab 和共享 state 按顺序推进实验。
- 通过 `execution_steps` 和 `current_execution` 识别每个 Lab 当前执行内容、资源名称、规则名称和下一步。
- 使用 Terraform 创建 EdgeOne Site。
- 完成域名所有权验证。
- 创建 EdgeOne 加速域名并配置源站。
- 配置 CNAME Setup 和 SSL 证书。
- 配置规则引擎，实现 HTTPS 跳转、缓存策略和版本更新规则。
- 理解 EdgeOne 安全策略、智能Bot 和 Web 安全模板的 Terraform 管理方式。
- 启用版本管理，创建初始配置组版本，更新版本，并把版本发布到 Production 和 Staging。
- 执行 Purge Cache、Prefetch URLs 和 destroy-only Resource Cleanup。
- 掌握常见接入、版本发布、缓存任务和清理问题的排查路径。

## 课前要求

学员需要提前准备：

- Tencent Cloud 账号。
- CAM SecretId / SecretKey。
- EdgeOne 可用套餐 `plan_id`。
- 一个测试域名，例如 `example.com`。
- 一个测试子域名，例如 `www.example.com`。
- DNS 管理权限，DNSPod 或其他 DNS 服务商均可。
- 一个公网可访问源站，例如源站 IP 或源站域名。
- 本地安装 Terraform、`curl`、`dig`。

## Day 1：`lab-01-provider-init` 到 `lab-07-ssl-certificate`，Terraform 基础、Site 接入与 HTTPS

| 时间 | 主题 | 内容 |
|---|---|---|
| 09:30-09:45 | 开场与实验目标 | 培训目标、实验架构、账号/域名/源站检查 |
| 09:45-10:05 | EdgeOne 与 Terraform 最小基础 | Site、加速域名、源站、CNAME、HTTPS、Provider、resource、data source、state |
| 10:05-10:25 | `lab-01-provider-init` | 初始化 Provider、local backend 和 `terraform_data.lab_sequence_guard`；不创建云资源，输出 `lab_id`、`lab_success`、`next_lab` 和 `workshop_result` |
| 10:25-10:40 | `lab-02-query-plans` | 使用只读 data source `tencentcloud_teo_zone_available_plans` 查询套餐，确认 `plan_id`；不创建云资源 |
| 10:40-10:50 | 休息 |  |
| 10:50-11:15 | `lab-03-create-site` | 使用 `tencentcloud_teo_zone` 创建 EdgeOne Site/Zone，配置 `zone_name`、`alias_zone_name`、`area` 和 `plan_id` |
| 11:15-11:35 | `lab-04-ownership-verify` | 使用 `tencentcloud_teo_ownership_verify` 发起所有权验证；可选创建 `tencentcloud_dnspod_record.ownership` |
| 11:35-11:55 | `lab-05-domain-management` | 使用 `tencentcloud_teo_acceleration_domain` 创建 `www` 加速域名，配置源站、Host Header、回源端口、回源协议和在线状态 |
| 11:55-12:10 | `lab-06-cname-setup` | 可选创建 `tencentcloud_dnspod_record.www_cname`；手工 DNS 模式下输出 EdgeOne CNAME，并用 `dig` 验证 |
| 12:10-12:30 | `lab-07-ssl-certificate` | 使用 `tencentcloud_teo_certificate_config` 为 `www` 配置 EdgeOne 免费证书或已有 SSL 证书，并验证 HTTPS |

## Day 2：`lab-08-rule-engine` 到 `lab-11-web-security-template`，规则引擎、安全策略、Bot 与安全模板

| 时间 | 主题 | 内容 |
|---|---|---|
| 09:30-09:45 | Day 1 回顾 | 检查共享 state、`lab_id` 顺序保护、CNAME、HTTPS、加速域名状态 |
| 09:45-10:15 | 规则引擎规则设计 | 匹配条件、action、HTTPS 强制跳转、缓存策略、动态页面不缓存 |
| 10:15-10:50 | `lab-08-rule-engine` | 使用 `tencentcloud_teo_l7_acc_rule_v2` 创建 `workshop-www-https-cache`，配置 HTTPS 强制跳转、静态资源 30 天缓存和动态页面 no-cache |
| 10:50-11:00 | 休息 |  |
| 11:00-11:30 | `lab-09-security-policy` | 使用 `tencentcloud_teo_security_policy_config` 配置 Monitor 模式 Custom Rule `monitor-curl-on-login` |
| 11:30-12:00 | `lab-10-bot-intelligence` | 启用 Bot Management 和智能Bot；新增 Bot Custom Rule `bot-monitor-api-curl`，High Risk/Likely Bot 使用 Monitor，Verified Bot/Human 使用 Allow |
| 12:00-12:25 | `lab-11-web-security-template` | 创建并绑定 `workshop_www_security`；模板包含 `monitor-curl-on-login`、`monitor-api-curl`、`bot-monitor-api-curl`、`login-single-ip-rate-limit` 和 `health-check-skip-security-modules` |
| 12:25-12:30 | Day 2 小结 | 汇总 Rule Engine、ZoneDefaultPolicy、Bot Management、Web 安全模板的资源名称、规则名称和标准输出 |

## Day 3：`lab-12-version-management` 到 `lab-16-resource-cleanup`，版本管理、缓存运维与资源清理

| 时间 | 主题 | 内容 |
|---|---|---|
| 09:30-09:45 | Day 2 回顾 | 检查规则引擎、安全策略、Bot、安全模板绑定状态 |
| 09:45-10:25 | `lab-12-version-management` | 启用 L7 版本管理，创建 `tencentcloud_teo_config_group_version.workshop_l7`，把包含 `workshop-www-https-cache` 的配置发布到 Production 和 Staging |
| 10:25-10:35 | 休息 |  |
| 10:35-11:15 | `lab-13-update-version` | 创建更新版本，新增规则引擎规则 `workshop-version-canary-no-cache`，匹配 `/version-canary/*` 并设置 no-cache，然后发布到 Production 和 Staging |
| 11:15-11:35 | `lab-14-purge-cache` | 使用 `tencentcloud_teo_purge_task.www_home` 对 `https://www.<zone_name>/` 执行 Purge Cache，输出 `purge_job_id` 和 `purge_targets` |
| 11:35-11:55 | `lab-15-prefetch-urls` | 使用 `tencentcloud_teo_prefetch_task_operation.www_home` 对 `https://www.<zone_name>/` 执行 Prefetch URLs，输出 `prefetch_job_id`、`prefetch_targets` 和 `prefetch_mode` |
| 11:55-12:20 | `lab-16-resource-cleanup` | 任意已完成 Lab 后均可进入；使用 `cleanup_confirm_destroy=true` 执行 destroy-only 清理，删除 Site、域名、证书、规则、安全策略、模板、版本、缓存任务和可选 DNSPod 记录 |
| 12:20-12:30 | 最终复盘 | 复盘顺序保护、版本管理后倒退执行限制、destroy-only 清理、幂等性和常见故障排查路径 |

## 时间分配说明

- Day 1 覆盖 `lab-01-provider-init` 到 `lab-07-ssl-certificate`，完成 Terraform 初始化、套餐查询、Site 创建、所有权验证、加速域名、CNAME 和 SSL 证书。
- Day 2 覆盖 `lab-08-rule-engine` 到 `lab-11-web-security-template`，完成规则引擎、安全策略、智能Bot 和 Web 安全模板。
- Day 3 覆盖 `lab-12-version-management` 到 `lab-16-resource-cleanup`，完成 Version Management、Update Version、Purge Cache、Prefetch URLs 和 destroy-only Resource Cleanup。

## 最终交付检查清单

培训结束时，学员应完成：

- Terraform 项目初始化。
- Credential 配置文件准备。
- `lab_id` 顺序保护验证。
- `execution_steps`、`current_execution`、`next_lab`、`workshop_result` 标准输出验证。
- EdgeOne 套餐查询。
- EdgeOne Site 创建。
- 域名所有权验证。
- 加速域名创建。
- 源站配置。
- CNAME 设置。
- SSL 证书配置。
- 规则引擎规则 `workshop-www-https-cache` 配置。
- 安全策略 Monitor 示例 `monitor-curl-on-login`。
- 智能Bot配置和 Bot Custom Rule `bot-monitor-api-curl`。
- Web 安全模板 `workshop_www_security` 创建与绑定，包含 `monitor-api-curl`、`login-single-ip-rate-limit` 和 `health-check-skip-security-modules`。
- 配置组版本管理、版本更新，并把版本发布到 Production 和 Staging。
- Lab 13 更新版本中新增规则引擎规则 `workshop-version-canary-no-cache`。
- 使用 `tencentcloud_teo_purge_task.www_home` 执行 Purge Cache。
- 使用 `tencentcloud_teo_prefetch_task_operation.www_home` 执行 Prefetch URLs。
- 使用 `cleanup_confirm_destroy=true` 完成 destroy-only 实验资源清理，并确认共享 state 清空。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
