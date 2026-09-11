# Lab 12：版本管理

Lab 目录：`lab-12-version-management`
Lab 名称：Lab 12：版本管理

## 目标

为 EdgeOne 站点的 L7 加速配置组启用版本控制模式，导出当前 L7 加速配置，创建一个新的配置组版本，并把该版本同时发布到 Production 和 Staging 环境。

本 Lab 不直接新增即时生效的 Rule Engine 规则，而是把当前 L7 加速配置打包为一个受版本管理的配置组版本。版本内容包含前序 Lab 已创建的 L7 规则：

- `workshop-www-https-cache`：包含 HTTPS 强制跳转、静态资源 30 天缓存和动态页面 no-cache 配置。

安全相关规则仍由 Zone Default Policy 和 Web 安全模板管理，包括 `monitor-curl-on-login`、`bot-monitor-api-curl`、`monitor-api-curl`、`login-single-ip-rate-limit` 和 `health-check-skip-security-modules`。本 Lab 的重点是把 L7 配置版本化，并发布到 Production 和 Staging。

本 Lab 位于 Web 安全模板之后、缓存运维实验之前，用于帮助学员理解 EdgeOne 配置变更的版本化流程：启用版本控制、导出配置、创建版本、发布版本。默认情况下 `enable_version_deploy = true`，Terraform 会自动发现 L7 配置组 ID、Production 环境 ID 和 Staging 环境 ID。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-12-version-management/terraform
```

## 准备变量

所有 Lab 共用配置文件。首次实验前只需要配置一次：

```bash
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

编辑 `labs/lab-common/terraform.tfvars` 和 `labs/lab-common/credentials.auto.tfvars`，填入你的测试域名、plan_id、源站和 CAM 凭证。本 Lab 通过 `-var-file=../../lab-common/...` 显式读取公共配置。

可选变量：

- `enable_version_management`：是否创建配置组版本，默认 `true`。
- `enable_version_deploy`：是否部署新版本，默认 `true`。默认会同时部署到 Production 和 Staging 环境。
- `version_group_id`：可选的 L7 配置组 ID。默认会自动使用 `discovered_version_group_id`；只有需要固定某个配置组时才需要手工填写。
- `version_env_id`：可选的环境 ID。默认会自动使用发现到的 Production 和 Staging 环境；只有需要覆盖为单个指定环境时才需要手工填写。

## 执行命令

切回 12 号 Lab 的 Terraform 目录：

```bash
cd ../lab-12-version-management/terraform
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

部署过程通常可能持续 10 分钟以上。首次启用版本管理前，Terraform 会先等待约 300 秒让前序配置收敛；启用后还会等待约 300 秒让 EdgeOne Production/Staging 环境 ready。期间看到 `Still creating...` 或 `Still modifying...` 属于正常现象，请等待

```bash
# 执行本 Lab 的 Terraform 变更，并把结果写入共享 state。
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

执行成功后，Terraform 会输出自动发现的 `discovered_version_group_id`、`discovered_production_env_id` 和 `discovered_staging_env_id`，以及新建的 `config_group_version_id`。启用版本管理后，Terraform 会等待约 300 秒再读取环境并发布版本，避免 EdgeOne 返回 `OperationDenied.EnvNotReady`。默认情况下，新版本会发布到 Staging，然后串行发布到 Production。

如果你希望固定使用指定配置组，或把部署覆盖为单个指定环境，也可以把它们写入 `labs/lab-common/terraform.tfvars`：

```hcl
version_group_id = "cg-xxxxxxxxxxxx"
version_env_id   = "env-xxxxxxxxxxxx"
```

然后执行 `terraform plan` 和 `terraform apply`，创建并部署配置组版本。

## 预期输出

- 完整 Terraform 输出列表：`lab_id`、`version_management_enabled`、`version_deploy_enabled`、`version_config_type`、`version_control_work_mode`、`version_env_id`、`discovered_version_env_id`、`discovered_production_env_id`、`discovered_staging_env_id`、`version_deploy_env_ids`、`version_group_id`、`discovered_version_group_id`、`version_resource_status`、`config_group_version_id`、`config_group_version_number`、`deploy_record_id`、`deploy_status`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
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
- `config_group_version_id`：初始配置组版本 ID。
- `config_group_version_number`：初始配置组版本号。
- `deploy_record_id`：初始版本发布记录 ID。
- `deploy_status`：初始版本发布状态。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-13-update-version`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- Terraform 能把 Zone 的 `l7_acceleration` work mode 配置为 `version_control`。
- Terraform 能通过 `tencentcloud_teo_export_zone_config` 导出 `L7AccelerationConfig`。
- Terraform 能通过 `tencentcloud_teo_environments` 查询 EdgeOne 环境，并自动使用发现到的 L7 配置组 ID 和环境 ID。
- `version_resource_status` 为 `created`。
- 如果 `version_resource_status = created`，`config_group_version_id` 应有值。
- 默认启用部署开关；`deploy_status` 应同时显示 Production 和 Staging 两个环境的部署结果。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
