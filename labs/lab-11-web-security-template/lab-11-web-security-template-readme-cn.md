# Lab 11：Web 安全模板 与域名绑定

Lab 目录：`lab-11-web-security-template`
Lab 名称：Lab 11：Web 安全模板

## 目标

创建 Web 安全模板，把 Lab 09/10 中的安全能力整理成可复用模板，并绑定到新建的 `www` 加速域名。

本 Lab 创建或保留的规则与动作如下：

- `workshop-www-https-cache`：沿用 Lab 08 的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源缓存和动态页面 no-cache。
- `monitor-curl-on-login`：保留在 `ZoneDefaultPolicy` 中，同时写入 Web 安全模板；匹配 `/login` + `curl` 请求，动作是 `Monitor`。
- `bot-monitor-api-curl`：保留在 `ZoneDefaultPolicy` 中，同时写入 Web 安全模板的 Bot Custom Rule；匹配 `/api` + `curl` 请求，动作是 `Monitor`。
- `monitor-api-curl`：新增到 Web 安全模板的 Custom Rule；匹配 `/api` + `curl` 请求，动作是 `Monitor`。
- `login-single-ip-rate-limit`：新增到 Web 安全模板的 Rate Limiting Rule；匹配 `/login` 请求，按客户端 IP 在 60 秒窗口内统计，阈值 300，命中后以 `Monitor` 观察 30 分钟。
- `health-check-skip-security-modules`：新增到 Web 安全模板的 Exception Rule；匹配 `/healthz`，跳过 Custom Rules、Rate Limiting 和 Bot 模块，避免健康检查被安全规则影响。

本 Lab 的 template 包含 Custom Rule、Bot Custom Rule、智能Bot、Rate Limiting 和 Exception Rule。完成后，学员应理解 Zone Default Policy 和 安全模板的差异，知道如何通过模板把安全策略绑定到指定域名，并能通过 output 核对模板名称、绑定域名和全部规则名称。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-11-web-security-template/terraform
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

切回 11 号 Lab 的 Terraform 目录：

```bash
cd ../lab-11-web-security-template/terraform
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

- 完整 Terraform 输出列表：`lab_id`、`web_security_template_enabled`、`web_security_template_id`、`web_security_template_name`、`web_security_template_bind_status`、`security_template_domain`、`lab_success`、`security_custom_rule_names`、`bot_custom_rule_names`、`rate_limiting_rule_names`、`exception_rule_names`、`new_rule_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `web_security_template_enabled`：是否启用 Web 安全模板。
- `web_security_template_id`：Web 安全模板 ID。
- `web_security_template_name`：Web 安全模板名称。
- `web_security_template_bind_status`：安全模板绑定状态。
- `security_template_domain`：绑定 安全模板的加速域名。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `security_custom_rule_names`：安全 Custom Rule 名称列表。
- `bot_custom_rule_names`：Bot Custom Rule 名称列表。
- `rate_limiting_rule_names`：Rate Limiting 规则名称列表。
- `exception_rule_names`：Exception Rule 名称列表。
- `new_rule_names`：本 Lab 新增或纳入管理的规则名称列表。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-12-version-management`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- Terraform 创建 `tencentcloud_teo_web_security_template.workshop`。
- Terraform 创建 `tencentcloud_teo_bind_security_template.www`。
- Template 中包含 `monitor-curl-on-login`、`bot-monitor-api-curl`、智能Bot、Rate Limiting 和 Exception Rule。
- `security_template_domain` 等于当前 `www` 加速域名。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
