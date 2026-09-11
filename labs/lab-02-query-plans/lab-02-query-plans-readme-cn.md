# Lab 02：查询 EdgeOne 套餐

Lab 目录：`lab-02-query-plans`
Lab 名称：Lab 02：查询套餐

## 目标

通过 Terraform data source 查询当前账号可用的 EdgeOne 套餐，并帮助学员确认后续创建站点 所需的 `plan_id`。

本 Lab 仍然不创建云资源，重点是让学员熟悉“只读查询”和“资源创建”的区别，理解 `data.tencentcloud_teo_zone_available_plans.available` 的用途，并能把查询结果和 `lab-common/terraform.tfvars` 中的 `plan_id` 对齐。

本 Lab 创建或管理的对象如下：

- `data.tencentcloud_teo_zone_available_plans.available`：只读查询当前账号可用的 EdgeOne 套餐列表，用于确认 `plan_id`。
- `terraform_data.lab_sequence_guard`：把共享 state 中的当前 Lab ID 更新为 `lab-02-query-plans`，供 Lab 03 检查顺序。
- 云资源：无。本 Lab 只查询套餐，不创建或修改 EdgeOne 资源。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 使用目录

```bash
cd labs/lab-02-query-plans/terraform
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

切回 02 号 Lab 的 Terraform 目录：

```bash
cd ../lab-02-query-plans/terraform
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

- 完整 Terraform 输出列表：`lab_id`、`available_edgeone_plans`、`lab_success`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `available_edgeone_plans`：当前账号可用的 EdgeOne 套餐列表。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-03-create-site`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- `terraform validate` 显示配置有效。
- `terraform apply` 完成且不创建云资源。
- 输出中包含可用于确认 `plan_id` 的 EdgeOne 套餐信息。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。

顺序保护允许本 Lab 在成功完成后再次执行 `terraform plan` 或 `terraform apply`；如果共享 state 的 `lab_id` 不是上一个 Lab 或当前 Lab，则会提示从 Lab 01 开始按顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
