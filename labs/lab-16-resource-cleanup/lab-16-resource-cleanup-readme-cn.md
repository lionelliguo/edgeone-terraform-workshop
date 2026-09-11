# Lab 16：资源清理

Lab 目录：`lab-16-resource-cleanup`
Lab 名称：Lab 16：资源清理

## 目标

使用 `terraform destroy` 清理本 workshop 创建或管理的 EdgeOne、DNSPod、安全模板、缓存任务等资源，并检查共享 state 是否已清空。

本 Lab 在任何已完成的 Lab 之后都可以执行，用于销毁当前共享 state 中已经创建或管理的 workshop 资源。清理目标包括：

- `tencentcloud_teo_prefetch_task_operation.www_home`：删除 URL 预热任务的 Terraform 管理记录。
- `tencentcloud_teo_purge_task.www_home`：删除 URL 刷新任务的 Terraform 管理记录。
- `tencentcloud_teo_deploy_config_group_version.*`：清理版本发布记录，包括初始版本和更新版本的 Staging、Production 或自定义环境发布记录。
- `tencentcloud_teo_config_group_version.*`：清理版本管理中创建的 L7 配置组版本。
- `tencentcloud_teo_bind_security_template.www`：解除 Web 安全模板与 `www` 加速域名的绑定。
- `tencentcloud_teo_web_security_template.workshop`：删除 Web 安全模板 `workshop_www_security`，以及模板内的 Custom Rule、Bot Custom Rule、Rate Limiting 和 Exception Rule。
- `tencentcloud_teo_security_policy_config.zone_default`：清理 Zone 默认安全策略中由 workshop 管理的 Monitor 规则和 Bot Intelligence 配置。
- `tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache`：删除 Rule Engine 规则 `workshop-www-https-cache`。
- `tencentcloud_teo_certificate_config.www`：删除 `www` 加速域名的证书配置。
- `tencentcloud_dnspod_record.www_cname`：可选资源。自动 DNSPod 模式下删除业务 CNAME 记录。
- `tencentcloud_teo_acceleration_domain.www`：删除 `www` 业务加速域名。
- `tencentcloud_teo_ownership_verify.zone` 和 `tencentcloud_dnspod_record.ownership`：清理所有权验证资源和可选 DNSPod 验证记录。
- `tencentcloud_teo_zone.zone`：删除 EdgeOne Zone。
- `terraform_data.lab_sequence_guard`：删除本地顺序保护记录。

本 Lab 的目标是建立完整实验闭环：创建、验证、变更、输出、清理。完成后，学员应知道哪些资源由 Terraform 自动销毁，哪些手工 DNS 记录需要在外部控制台自行删除，以及如何用 `terraform state list` 验证清理结果。

## 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。Lab 16 是 destroy-only Lab，可以在任意已完成 Lab 之后执行，用于清理此前已经写入共享 state 的 workshop 资源；也可重复执行 `plan -destroy` 或 `destroy`，清理完成后再次执行应保持空 state，不会删除额外资源。

## 使用目录

```bash
cd labs/lab-16-resource-cleanup/terraform
```

## 准备变量

所有 Lab 共用配置文件。首次实验前只需要配置一次：

```bash
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

编辑 `labs/lab-common/terraform.tfvars` 和 `labs/lab-common/credentials.auto.tfvars`，填入你的测试域名、plan_id、源站和 CAM 凭证。

## 执行命令

切回 16 号 Lab 的 Terraform 目录：

```bash
cd ../lab-16-resource-cleanup/terraform
```

```bash
# 初始化当前 Lab 的 backend 和 TencentCloud Provider。
terraform init
# 格式化当前目录下的 Terraform 配置文件。
terraform fmt
# 校验 Terraform 配置语法和 provider schema 是否有效。
terraform validate
```

执行清理：

注意：Lab 16 是 destroy-only 清理 Lab。无论你当前完成到 Lab 03、Lab 10、Lab 13 还是 Lab 15，都可以进入本 Lab 清理此前已经创建并写入共享 state 的资源。不要执行普通 `terraform apply`；普通 apply 不会删除资源，并且现在会被配置保护拒绝。

部署过程通常可能持续约 5 分钟，期间看到 `Still creating...` 或 `Still modifying...` 属于正常现象，请等待

```bash
# 预览将被销毁的 workshop 资源，不会实际删除资源。
terraform plan -destroy -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars -var="cleanup_confirm_destroy=true"
# 按当前 Terraform state 删除 workshop 管理的资源。
terraform destroy -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars -var="cleanup_confirm_destroy=true"
```

## 预期输出

- 完整 Terraform 输出列表：`lab_id`、`lab_success`、`cleanup_resource_names`、`created_resource_names`、`current_execution`、`execution_steps`、`next_lab`、`workshop_result`。
- `lab_id`：最近完成并写入共享 state 的 Lab 编号，用于后续 Lab 的顺序保护。
- `lab_success`：Lab 完成状态。`success` 表示本 Lab 目标已经完成。
- `cleanup_resource_names`：Lab 16 destroy 前列出的清理目标资源名称和规则名称。
- `created_resource_names`：本 Lab 创建或管理的资源名称摘要，保留用于兼容早期版本。
- `current_execution`：本 Lab 当前执行内容摘要，包括 action、execution_mode、资源名称、规则名称、关键动作和下一步。
- `execution_steps`：按步骤列出本 Lab 创建、修改或销毁的资源，包含资源类型、资源名称、关键 ID、规则名称、动作和目标等细节。
- `next_lab`：本 Lab 成功后建议继续执行的下一个 Lab。 下一个 Lab：`lab-01-provider-init`。
- `workshop_result`：最终结果摘要，固定包含 `lab_id`、`lab_success` 和 `next_lab`。

## 成功标准

- `terraform plan -destroy` 显示将删除预期的 EdgeOne 和可选 DNSPod 资源。
- `terraform destroy` 成功完成。
- 清理后执行 `terraform state list` 不再返回 workshop 管理的资源。

## State 说明

本 Lab 使用共享 local backend：`shared/edgeone-workshop.tfstate`。从上一个 Lab 切换过来后，请重新执行 `terraform init`。普通 `apply` 会被 `sequence_guard.tf` 阻止；请只使用 `plan -destroy` 和 `destroy`。清理完成后共享 state 为空，再次执行本 Lab 的 destroy 命令应是 no-op。

顺序保护允许本 Lab 从任意已完成 Lab 的共享 state 进入，也允许在成功清理后再次执行 `plan -destroy` 或 `destroy`。Lab 16 仍然是 destroy-only Lab，不支持普通 `apply`。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
