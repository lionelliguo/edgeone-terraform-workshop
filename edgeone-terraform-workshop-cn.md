# Tencent Cloud EdgeOne Terraform Workshop 培训包说明

版本日期：2026-08-01  
适配日程：3 天培训，每天 3 小时，EdgeOne 实操优先版

## 培训包目标

本培训包用于指导学员通过 Terraform 创建和验证 Tencent Cloud EdgeOne 接入链路。课程把 Terraform 内容控制在完成实验所需范围内，重点放在 EdgeOne 站点创建、域名验证、加速域名、CNAME、HTTPS、L7 规则、安全策略和故障排查。

完成培训后，学员应能够：

- 使用配置文件方式管理 Tencent Cloud CAM 凭证。
- 初始化 TencentCloud Terraform Provider。
- 查询 EdgeOne 可用套餐并确认 `plan_id`。
- 创建 EdgeOne 站点。
- 完成域名所有权验证。
- 创建业务加速域名并配置源站。
- 配置业务 CNAME 和 HTTPS 证书。
- 配置基础 L7 加速规则。
- 通过 Monitor 模式理解安全策略管理方式。
- 使用 Terraform plan、apply、state、output 和 destroy 完成完整实验闭环。
- 配置智能Bot、Web 安全模板、缓存刷新和缓存预热等扩展实验。

## 目录结构

```text
edgeone-terraform-workshop/
  edgeone-terraform-workshop-cn.md
  edgeone-terraform-workshop-en.md
  agenda/
    agenda-3day-3hour-cn.md
    agenda-3day-3hour-en.md
    agenda-3day-3hour-cn.docx
    agenda-3day-3hour-en.docx
  labs/
    lab-guide-cn.md
    lab-guide-en.md
    lab-common/
      lab-common-readme-cn.md
      lab-common-readme-en.md
      terraform.tfvars.example
      credentials.auto.tfvars.example
    lab-01-provider-init/
      lab-01-provider-init-readme-cn.md
      lab-01-provider-init-readme-en.md
      terraform/
    lab-02-query-plans/
      lab-02-query-plans-readme-cn.md
      lab-02-query-plans-readme-en.md
      terraform/
    lab-03-create-site/
      lab-03-create-site-readme-cn.md
      lab-03-create-site-readme-en.md
      terraform/
    lab-04-ownership-verify/
      lab-04-ownership-verify-readme-cn.md
      lab-04-ownership-verify-readme-en.md
      terraform/
    lab-05-domain-management/
      lab-05-domain-management-readme-cn.md
      lab-05-domain-management-readme-en.md
      terraform/
    lab-06-cname-setup/
      lab-06-cname-setup-readme-cn.md
      lab-06-cname-setup-readme-en.md
      terraform/
    lab-07-ssl-certificate/
      lab-07-ssl-certificate-readme-cn.md
      lab-07-ssl-certificate-readme-en.md
      terraform/
    lab-08-rule-engine/
      lab-08-rule-engine-readme-cn.md
      lab-08-rule-engine-readme-en.md
      terraform/
    lab-09-security-policy/
      lab-09-security-policy-readme-cn.md
      lab-09-security-policy-readme-en.md
      terraform/
    lab-10-bot-intelligence/
      lab-10-bot-intelligence-readme-cn.md
      lab-10-bot-intelligence-readme-en.md
      terraform/
    lab-11-web-security-template/
      lab-11-web-security-template-readme-cn.md
      lab-11-web-security-template-readme-en.md
      terraform/
    lab-12-version-management/
      lab-12-version-management-readme-cn.md
      lab-12-version-management-readme-en.md
      terraform/
    lab-13-update-version/
      lab-13-update-version-readme-cn.md
      lab-13-update-version-readme-en.md
      terraform/
    lab-14-purge-cache/
      lab-14-purge-cache-readme-cn.md
      lab-14-purge-cache-readme-en.md
      terraform/
    lab-15-prefetch-urls/
      lab-15-prefetch-urls-readme-cn.md
      lab-15-prefetch-urls-readme-en.md
      terraform/
    lab-16-resource-cleanup/
      lab-16-resource-cleanup-readme-cn.md
      lab-16-resource-cleanup-readme-en.md
      terraform/
  shared/
    shared-readme-cn.md
    shared-readme-en.md
```

说明：

- `labs/lab-xx-*/terraform/` 是课堂递进式代码，每个 Lab 只包含当前阶段需要的 Terraform 配置。
- `labs/lab-common/` 保存所有 Lab 共用的 `terraform.tfvars` 和 `credentials.auto.tfvars`。
- 每个 Lab 通过 `-var-file=../../lab-common/...` 显式读取公共配置。
- 所有 Lab 目录通过 local backend 共用 `shared/edgeone-workshop.tfstate`，可以按顺序连续执行。
- `shared/` 是 Terraform state 共享目录，运行后会生成 `edgeone-workshop.tfstate`，正式交付包不会包含真实 state。
- 正式培训建议学员使用 `labs/lab-xx-*/terraform/` 中的递进式 Lab。
- 从 Lab 12 启用 Version Management 后，Lab 01 到 Lab 11 会拒绝执行，避免在 `version_control` 模式下修改早期即时生效配置。需要重新开始时，请先执行 Lab 16 清理资源和共享 state。
- Lab 16 是 destroy-only 清理 Lab，可以在任意已完成 Lab 之后执行，用于清理此前已经创建并写入共享 state 的资源；必须使用带 `cleanup_confirm_destroy=true` 的 `terraform plan -destroy` 和 `terraform destroy`，普通 `terraform apply` 不会删除资源。
- 部分 Lab 的 `terraform/removed.tf` 用于兼容后续 Lab 留下的 state 记录，只从 state 中遗忘，不销毁云上资源。如果看到 “will no longer be managed by Terraform, but will not be destroyed”，这是 state 兼容处理的预期提示；真正的执行仍会受到顺序保护限制。

## Workshop 执行规则

- Lab 01 开始前，先进入 `labs/lab-01-provider-init/terraform` 并执行 `./reset-shared-state.sh`，把共享 state 清理为初始状态。该脚本只清理本地 state，不删除云上资源。
- 所有 Lab 必须按照 `lab-01` 到 `lab-16` 的顺序执行。每个 Lab 的 `sequence_guard.tf` 会在 Terraform 执行时检查共享 state 中的上一个 `lab_id`；如果顺序不正确，会提示从 Lab 01 开始按顺序执行，并阻止本次资源变更。
- 每个 Lab 都按幂等方式设计。相同 Lab 可以重复执行 `plan` 或 `apply`；在资源已符合配置时，Terraform 应显示 no changes 或不改变最终结果。
- README 中统一使用 Terraform 原生命令 `terraform plan/apply/destroy`。顺序保护由每个 Lab 的 `sequence_guard.tf` 执行。

## Credential 配置

本 workshop 使用配置文件方式提供凭证。学员复制示例文件：

```bash
cd labs/lab-common
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

填写：

```hcl
tencentcloud_secret_id  = "REPLACE_WITH_TENCENTCLOUD_SECRET_ID"
tencentcloud_secret_key = "REPLACE_WITH_TENCENTCLOUD_SECRET_KEY"
```

安全要求：

- 不要提交 `credentials.auto.tfvars`。
- 不要在截图、录屏或聊天工具中暴露真实密钥。
- 培训结束后建议禁用或删除临时 CAM 密钥。
- 生产环境建议改用 CI/CD Secret、临时凭证、角色授权或 OIDC。

## Terraform 执行路径

每个 Lab 使用自己的目录。例如：

```bash
cd labs/lab-01-provider-init/terraform
./reset-shared-state.sh
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
cd ../..

cd labs/lab-03-create-site/terraform
terraform init
terraform fmt
terraform validate
terraform plan -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

进入下一个 Lab 时，切换到下一个目录：

```bash
cd ../../lab-04-ownership-verify/terraform
terraform init
```

## 真实执行条件

```text
1. Tencent Cloud CAM 凭证有效。
2. CAM 权限包含 EdgeOne、SSL Certificate 和 DNSPod 相关权限。
3. EdgeOne plan_id 可用。
4. 测试域名可控。
5. DNS 验证记录可以创建。
6. 源站公网可访问。
7. 业务 CNAME 可以指向 EdgeOne 分配的 CNAME。
```

## 预期结果

Terraform 输出示例：

```text
zone_id = "zone-xxxxxx"
acceleration_domain = "www.example.com"
edgeone_cname = "www.example.com.eo.dnse0.com"
```

DNS 验证：

```bash
dig +short CNAME www.example.com
```

预期返回：

```text
www.example.com.eo.dnse0.com.
```

访问验证：

```bash
curl -I http://www.example.com
curl -I https://www.example.com
```

HTTP 预期看到 EdgeOne 响应头，例如：

```text
Server: TencentEdgeOne
```

HTTPS 状态码取决于证书、回源协议和源站可用性。

## 交付说明

正式交付建议使用：

```text
outputs/edgeone-terraform-workshop.zip
```

该压缩包不应包含真实凭证、真实 `terraform.tfvars`、state backup 或 `.terraform/` 目录。`shared/edgeone-workshop.tfstate` 保留为空初始 state，用于 Workshop 顺序执行。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
