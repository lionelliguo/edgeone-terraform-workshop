# Lab 01：Provider 初始化

Lab 目录：`lab-01-provider-init`
Lab 名称：Lab 01：Provider 初始化

## 目标

初始化本 workshop 的 Terraform 执行环境，并确认 TencentCloud Provider 可以被正确加载。完成本 Lab 后，学员应理解 Terraform 工作目录、provider 配置、公共变量文件和共享 state 之间的关系。

本 Lab 不创建任何云资源，重点是建立后续实验的执行基线：`terraform init` 能下载 provider，`terraform validate` 能通过配置校验，`terraform plan` 能在读取公共配置后正常运行。

本 Lab 创建或管理的对象如下：

- `terraform_data.lab_sequence_guard`：写入当前 Lab ID，用于后续 Lab 的顺序保护。
- Terraform local backend：使用 `shared/edgeone-workshop.tfstate` 作为所有 Lab 共享 state 文件。
- TencentCloud Provider 配置：读取 `lab-common/credentials.auto.tfvars` 中的 CAM 凭证，用于后续访问 EdgeOne API。
- 云资源：无。本 Lab 不创建 EdgeOne、DNSPod、证书或安全资源。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-01-provider-init/terraform
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

切回 Lab 01 的 Terraform 目录：

```bash
cd ../lab-01-provider-init/terraform
```

从 Lab 01 开始整个 workshop 前，请先清空之前残留的共享 state：

```bash
./reset-shared-state.sh
```

该脚本只删除本地 `shared/edgeone-workshop.tfstate` 及其备份/锁文件，不会删除云上资源。执行时需要输入 `RESET` 确认。首次开始或重新开始 workshop 时请先执行它，确保后续 Lab 的顺序保护从初始状态开始。

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

Lab 01 只做初始化和验证，不创建云资源。

如果需要把 `lab_success` 写入共享 state 并在 `terraform output` 中查看，执行：

部署过程通常可能持续约 5 分钟，期间看到 `Still creating...` 或 `Still modifying...` 属于正常现象，请等待

```bash
# 执行本 Lab 的 Terraform 变更，并把结果写入共享 state。
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

## 预期输出

- 完整 Terraform 输出列表：`lab_id`、`lab_success`、`created_resource_names`、`current_execution`、`ownership_verification`、`zone_id`、`zone_name`、`zone_status`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `ownership_verification`：域名所有权 DNS 验证信息。
- `zone_id`：EdgeOne Zone/Site ID。
- `zone_name`：EdgeOne Zone/Site 名称。
- `zone_status`：当前 Zone/Site 状态。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-02-query-plans`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- `terraform init` 成功完成。
- `terraform validate` 显示配置有效。
- `terraform plan` 不显示需要创建的云资源。
- 执行 `terraform apply` 后，`terraform output lab_success` 返回 `success`。
- Lab 01 只允许在空共享 state 或已经完成 Lab 01 的 state 上重复执行。
- 如果共享 state 来自 Lab 02 或更后的 Lab，Terraform 会拒绝执行并提示先清理或重置 state 后再从 Lab 01 开始。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。Lab 01 支持空 state 初始化，也支持在 `lab_id = lab-01-provider-init` 时重复执行 `terraform plan` 或 `terraform apply`。如果共享 state 已经由 Lab 02 或更后的 Lab 写入，Lab 01 会拒绝执行，避免把后续资源从 Terraform 管理中移除。若要重新开始整个 workshop，请先运行 Lab 16 Resource Cleanup，或在确认不再需要当前 state 跟踪信息后运行 `./reset-shared-state.sh`。如果错误提示前出现 “will no longer be managed by Terraform, but will not be destroyed”，这是 Terraform 在 sequence guard 拒绝执行前根据 state/config 差异打印的保护性提示；它不会删除云资源。只要后面同时出现 `Lab 01 sequence check failed`，就说明顺序保护已生效。不要输入 yes，也不要继续 apply；请先执行 Lab 16 清理，或确认后重置 `shared/edgeone-workshop.tfstate` 再从 Lab 01 开始。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
