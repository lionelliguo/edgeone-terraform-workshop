# Lab 13：更新版本

Lab 目录：`lab-13-update-version`
Lab 名称：Lab 13：更新版本

## 目标

基于 Lab 12 已启用的 EdgeOne Version Management，导出当前 L7 加速配置，生成一个更新后的配置组版本，并把新版本同时发布到 Production 和 Staging 环境。

本 Lab 通过版本管理方式创建或保留的规则与动作如下：

- `workshop-www-https-cache`：保留前序版本中的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源 30 天缓存和动态页面 no-cache。
- `workshop-version-canary-no-cache`：新增到更新版本中的 Rule Engine 规则；匹配 `/version-canary/*` 路径并设置 no-cache，用于演示版本化发布下的灰度验证路径。

本 Lab 不会直接调用即时生效的 L7 Rule API 修改线上规则，而是导出当前 `L7AccelerationConfig`，生成新的配置组版本，再发布到 Staging 和 Production。安全相关规则继续由前序的 Zone Default Policy 和 Web 安全模板管理。

本 Lab 用于演示版本控制模式下的推荐变更流程：不再直接调用即时生效的 L7 Rule API，而是通过导出配置、生成新版本、发布版本来完成配置更新。为了让版本差异更清晰，本 Lab 会把原规则描述更新为 `Managed by Terraform workshop - updated version`，并新增一条 规则引擎规则 `workshop-version-canary-no-cache`。该规则只匹配 `/version-canary/*` 路径并设置不缓存，不改变已有 HTTPS 跳转、静态资源缓存或源站配置。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-13-update-version/terraform
```

## 准备变量

所有 Lab 共用配置文件。首次实验前只需要配置一次：

```bash
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

编辑 `labs/lab-common/terraform.tfvars` 和 `labs/lab-common/credentials.auto.tfvars`，填入你的测试域名、plan_id、源站和 CAM 凭证。本 Lab 通过 `-var-file=../../lab-common/...` 显式读取公共配置。

## 执行命令

切回 13 号 Lab 的 Terraform 目录：

```bash
cd ../lab-13-update-version/terraform
```

```bash
# 初始化当前 Lab 的 backend 和 TencentCloud Provider。
terraform init
# 格式化当前目录下的 Terraform 配置文件。
terraform fmt
# 校验 Terraform 配置语法和 provider schema 是否有效。
terraform validate
# 预览本 Lab 将执行的 Terraform 变更，不会实际修改云资源。
terraform plan -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

如果 plan 符合预期，执行：

部署过程通常可能持续 10 分钟以上。Terraform 会先等待约 300 秒让版本管理环境和前序发布状态收敛；随后再等待约 300 秒读取环境并发布更新版本。期间看到 `Still creating...` 或 `Still modifying...` 属于正常现象，请等待

```bash
# 执行本 Lab 的 Terraform 变更，并把结果写入共享 state。
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

## 预期输出

- 完整 Terraform 输出列表：`lab_id`、`version_management_enabled`、`version_deploy_enabled`、`version_config_type`、`version_control_work_mode`、`version_env_id`、`discovered_version_env_id`、`discovered_production_env_id`、`discovered_staging_env_id`、`version_deploy_env_ids`、`version_group_id`、`discovered_version_group_id`、`version_resource_status`、`updated_version_resource_status`、`config_group_version_id`、`config_group_version_number`、`deploy_record_id`、`deploy_status`、`updated_config_group_version_id`、`updated_config_group_version_number`、`updated_rule_engine_rule_name`、`updated_deploy_record_id`、`updated_deploy_status`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `version_management_enabled`：是否启用版本管理。
- `version_deploy_enabled`：是否启用版本发布。
- `version_config_type`：版本管理配置类型。
- `version_control_work_mode`：版本控制工作模式。
- `version_env_id`：兼容旧版本的有效环境 ID。
- `discovered_version_env_id`：自动发现的环境 ID。
- `discovered_production_env_id`：自动发现的 Production 环境 ID。
- `discovered_staging_env_id`：自动发现的 Staging 环境 ID。
- `version_deploy_env_ids`：版本发布目标环境 ID。
- `version_group_id`：用于创建版本的配置组 ID。
- `discovered_version_group_id`：自动发现的配置组 ID。
- `version_resource_status`：初始配置组版本资源状态。
- `updated_version_resource_status`：更新配置组版本资源状态。
- `config_group_version_id`：初始配置组版本 ID。
- `config_group_version_number`：初始配置组版本号。
- `deploy_record_id`：初始版本发布记录 ID。
- `deploy_status`：初始版本发布状态。
- `updated_config_group_version_id`：更新配置组版本 ID。
- `updated_config_group_version_number`：更新配置组版本号。
- `updated_rule_engine_rule_name`：更新版本新增的 规则引擎规则名称。
- `updated_deploy_record_id`：更新版本发布记录 ID。
- `updated_deploy_status`：更新版本发布状态。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-14-purge-cache`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- Terraform 不再尝试创建或修改 `tencentcloud_teo_l7_acc_rule_v2`，避免版本控制锁定错误。
- Terraform 创建 `tencentcloud_teo_config_group_version.workshop_l7_update`。
- 更新版本内容包含新增规则引擎规则 `workshop-version-canary-no-cache`。
- Terraform 创建 `tencentcloud_teo_deploy_config_group_version.workshop_l7_update["production"]` 和 `["staging"]`。
- `updated_config_group_version_id` 有值。
- `updated_deploy_status` 同时返回 Production 和 Staging 的发布结果。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
