# Lab 10：配置智能Bot

Lab 目录：`lab-10-bot-intelligence`
Lab 名称：Lab 10：智能Bot

## 目标

在 Lab 09 的基础上启用 Bot Management 和智能Bot，并为高风险 Bot 请求配置 Monitor 动作。

本 Lab 创建或保留的规则与动作如下：

- `workshop-www-https-cache`：沿用 Lab 08 的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源缓存和动态页面 no-cache。
- `monitor-curl-on-login`：沿用 Lab 09 的 Web Security Custom Rule，继续以 `Monitor` 观察 `/login` + `curl` 请求。
- `bot-monitor-api-curl`：新增到 Bot Management 的 Bot Custom Rule，匹配路径包含 `/api` 且 User-Agent 包含 `curl` 的请求，动作是 `Monitor`。
- Bot Intelligence 分类动作：High Risk Bot 和 Likely Bot 使用 `Monitor`，Verified Bot 和 Human 使用 `Allow`。

本 Lab 同时新增 Bot Custom Rule `bot-monitor-api-curl`，匹配 `/api` + `curl` 的请求并执行 Monitor。完成后，学员应能区分 Web Security Custom Rule 和 Bot Custom Rule，理解 High Risk Bot、Likely Bot、Verified Bot、Human 不同分类的处理动作。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-10-bot-intelligence/terraform
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

切回 10 号 Lab 的 Terraform 目录：

```bash
cd ../lab-10-bot-intelligence/terraform
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

部署过程通常可能持续约 5 分钟，期间看到 `Still creating...` 或 `Still modifying...` 属于正常现象，请等待

```bash
# 执行本 Lab 的 Terraform 变更，并把结果写入共享 state。
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

## 预期输出

- 完整 Terraform 输出列表：`lab_id`、`bot_intelligence_enabled`、`security_policy_id`、`bot_high_risk_action`、`bot_custom_rule_name`、`lab_success`、`security_custom_rule_names`、`bot_custom_rule_names`、`new_rule_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `bot_intelligence_enabled`：是否启用智能Bot配置。
- `security_policy_id`：安全策略配置 ID。
- `bot_high_risk_action`：高风险 Bot 请求动作。
- `bot_custom_rule_name`：Bot Custom Rule 名称。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `security_custom_rule_names`：安全 Custom Rule 名称列表。
- `bot_custom_rule_names`：Bot Custom Rule 名称列表。
- `new_rule_names`：本 Lab 新增或纳入管理的规则名称列表。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-11-web-security-template`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- Terraform 管理 `tencentcloud_teo_security_policy_config.zone_default`。
- `security_policy_id` 有值。
- `bot_high_risk_action` 输出为 `Monitor`。
- Bot Management 中包含 `bot-monitor-api-curl` 自定义规则，匹配 `/api` + `curl` 并执行 Monitor。
- 首次成功执行后，再次执行 `terraform plan` 或 `terraform apply` 应显示 `No changes`；EdgeOne API 自动回填的 Bot 默认空配置不会触发二次变更。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
