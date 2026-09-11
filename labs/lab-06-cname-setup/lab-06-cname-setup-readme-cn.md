# Lab 06：CNAME 配置

Lab 目录：`lab-06-cname-setup`
Lab 名称：Lab 06：CNAME 设置

## 目标

配置或输出业务域名到 EdgeOne CNAME 的解析关系，使用户访问路径能够进入 EdgeOne。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：继续管理 EdgeOne Zone。
- `tencentcloud_teo_acceleration_domain.www`：继续管理 `www` 加速域名，并读取 EdgeOne 分配的 CNAME。
- `tencentcloud_dnspod_record.www_cname`：可选资源。启用 `auto_create_dnspod_records` 时创建业务域名的 CNAME 记录，把 `www` 指向 EdgeOne CNAME；关闭时不创建，仅输出 `edgeone_cname`。
- `tencentcloud_dnspod_record.ownership`：可选资源。自动 DNSPod 模式下继续管理所有权验证记录。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 07 只能在 Lab 06 之后执行。

如果启用 DNSPod 自动化，本 Lab 会创建业务 CNAME 记录；如果使用手工 DNS 模式，本 Lab 会输出准确的 `edgeone_cname` 供学员在 DNS 控制台配置。完成后，学员应能理解 CNAME 生效、DNS 传播和 `dig`/`curl` 验证之间的关系。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-06-cname-setup/terraform
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

切回 06 号 Lab 的 Terraform 目录：

```bash
cd ../lab-06-cname-setup/terraform
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

- 完整 Terraform 输出列表：`lab_id`、`acceleration_domain`、`edgeone_cname`、`dnspod_cname_record_id`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `acceleration_domain`：EdgeOne 加速域名。
- `edgeone_cname`：EdgeOne 分配的 CNAME。
- `dnspod_cname_record_id`：DNSPod CNAME 记录 ID；未启用自动 DNSPod 时为 null。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-07-ssl-certificate`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- 业务域名已经具备指向 EdgeOne 的 CNAME 路径。
- 如果 `auto_create_dnspod_records = true`，Terraform 创建 DNSPod CNAME 记录。
- 如果未启用 DNS 自动化，输出提供了手工配置所需的准确 CNAME 目标。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
