# Common Lab Configuration

## 目标

集中保存所有 Lab 共用的变量和凭证文件，避免学员在每个 Lab 目录中重复填写域名、源站、套餐 ID 和 CAM 密钥。

完成本配置步骤后，学员应理解 `terraform.tfvars` 与 `credentials.auto.tfvars` 的分工：前者保存实验参数，后者保存敏感凭证；正式交付包只包含 `.example` 示例文件，不包含真实配置。

## Workshop 运行规则

- Lab 01 开始前，先在 `labs/lab-01-provider-init/terraform` 执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有可执行 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个可执行 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。

## 初始化

```bash
cd labs/lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

编辑：

```text
terraform.tfvars
credentials.auto.tfvars
```

每个 Lab 的 `terraform/` 目录都通过 `-var-file=../../lab-common/...` 显式读取这里的配置文件，因此只需要配置一次。

## 共享变量说明

`terraform.tfvars` 中包含所有 Lab 共用的实验参数。`alias_zone_name` 是 EdgeOne 控制台显示的站点别名，必须与 `zone_name` 不同；示例使用 `example.com-workshop`，真实测试可使用类似 `your-domain.com-workshop` 的值。`enable_version_deploy = true` 用于 Lab 12 和 Lab 13 的版本管理实验。Lab 12 会启用版本控制，导出 L7 配置，创建配置组版本，并在发现 Production 和 Staging 环境后把最新版本同时部署到两个环境。Lab 13 会基于当前 L7 配置创建一个更新版本，新增规则引擎规则 `workshop-version-canary-no-cache`，并再次发布到 Production 和 Staging。Lab 16 是 destroy-only 清理 Lab，可以在任意已完成 Lab 之后执行，用于清理此前已经创建并写入共享 state 的资源；必须使用 `cleanup_confirm_destroy=true` 执行 `terraform plan -destroy` 和 `terraform destroy`。`version_group_id` 和 `version_env_id` 仍然是可选覆盖参数；默认情况下不需要手工填写发现到的 ID。

## 安全

不要提交 `terraform.tfvars`、`credentials.auto.tfvars` 或任何真实密钥。

## 输出说明

所有可执行 Lab 都输出 `current_execution`，用于显示当前执行内容、资源名称、规则名称、关键动作和下一步。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
