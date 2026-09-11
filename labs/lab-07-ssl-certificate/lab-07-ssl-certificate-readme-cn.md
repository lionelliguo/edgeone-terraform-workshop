# Lab 07：SSL 证书

Lab 目录：`lab-07-ssl-certificate`
Lab 名称：Lab 07：SSL 证书

## 目标

为 `www` 加速域名启用 HTTPS 证书配置，支持 EdgeOne 免费证书或已有 SSL 证书两种模式。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：继续管理 EdgeOne Zone。
- `tencentcloud_teo_acceleration_domain.www`：继续管理 `www` 加速域名，作为证书绑定目标。
- `tencentcloud_teo_certificate_config.www`：为 `www` 加速域名配置证书。`certificate_mode = "eofreecert"` 时申请/使用 EdgeOne 免费证书；`certificate_mode = "sslcert"` 时绑定 `ssl_cert_id` 指定的已有证书。
- `tencentcloud_dnspod_record.www_cname`：可选资源。自动 DNSPod 模式下继续管理业务 CNAME 记录。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 08 只能在 Lab 07 之后执行。

本 Lab 的目标不是深入讲解证书生命周期，而是让学员掌握 Terraform 如何把证书模式、证书 ID 和加速域名绑定起来。完成后，学员应能通过 output 核对证书配置 ID、证书模式和受保护的 host。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-07-ssl-certificate/terraform
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

切回 07 号 Lab 的 Terraform 目录：

```bash
cd ../lab-07-ssl-certificate/terraform
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

- 完整 Terraform 输出列表：`lab_id`、`https_host`、`certificate_mode`、`certificate_config_id`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `https_host`：配置 SSL 证书的主机名。
- `certificate_mode`：证书配置模式。
- `certificate_config_id`：EdgeOne 证书配置 ID。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-08-rule-engine`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- 当 `enable_certificate = true` 时，Terraform 创建 `tencentcloud_teo_certificate_config.www`。
- 启用证书配置时，`certificate_config_id` 有值。
- 证书配置的 host 与加速域名一致。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
