# Tencent Cloud EdgeOne Terraform Workshop

适配日程：3 天培训，每天 3 小时，EdgeOne 实操优先版

## Workshop 目标

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

## Lab 目标

### Lab 01：Provider 初始化

初始化本 workshop 的 Terraform 执行环境，并确认 TencentCloud Provider 可以被正确加载。完成本 Lab 后，学员应理解 Terraform 工作目录、provider 配置、公共变量文件和共享 state 之间的关系。

本 Lab 不创建任何云资源，重点是建立后续实验的执行基线：`terraform init` 能下载 provider，`terraform validate` 能通过配置校验，`terraform plan` 能在读取公共配置后正常运行。

本 Lab 创建或管理的对象如下：

- `terraform_data.lab_sequence_guard`：写入当前 Lab ID，用于后续 Lab 的顺序保护。
- Terraform local backend：使用 `shared/edgeone-workshop.tfstate` 作为所有 Lab 共享 state 文件。
- TencentCloud Provider 配置：读取 `lab-common/credentials.auto.tfvars` 中的 CAM 凭证，用于后续访问 EdgeOne API。
- 云资源：无。本 Lab 不创建 EdgeOne、DNSPod、证书或安全资源。

### Lab 02：查询 EdgeOne 套餐

通过 Terraform data source 查询当前账号可用的 EdgeOne 套餐，并帮助学员确认后续创建站点 所需的 `plan_id`。

本 Lab 仍然不创建云资源，重点是让学员熟悉“只读查询”和“资源创建”的区别，理解 `data.tencentcloud_teo_zone_available_plans.available` 的用途，并能把查询结果和 `lab-common/terraform.tfvars` 中的 `plan_id` 对齐。

本 Lab 创建或管理的对象如下：

- `data.tencentcloud_teo_zone_available_plans.available`：只读查询当前账号可用的 EdgeOne 套餐列表，用于确认 `plan_id`。
- `terraform_data.lab_sequence_guard`：把共享 state 中的当前 Lab ID 更新为 `lab-02-query-plans`，供 Lab 03 检查顺序。
- 云资源：无。本 Lab 只查询套餐，不创建或修改 EdgeOne 资源。

### Lab 03：创建 EdgeOne 站点

创建 EdgeOne Zone，建立后续域名验证、加速域名、HTTPS、L7 规则和安全策略的基础资源。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：创建 EdgeOne 站点 Zone，使用 `partial` 接入模式、指定 `area`、`plan_id`、`zone_name` 和 `alias_zone_name`。
- `data.tencentcloud_teo_zone_available_plans.available`：只读查询可用套餐，帮助确认当前配置的 `plan_id` 可用。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 04 只能在 Lab 03 之后执行。

完成本 Lab 后，学员应能在 Terraform output 和 EdgeOne 控制台中核对 Zone 名称、Zone ID、别名和状态，并理解为什么新建 Zone 通常还需要完成所有权验证才能进入可用状态。

### Lab 04：域名所有权验证

完成 EdgeOne 对站点域名的所有权验证，让 Zone 从“已创建”进入可继续接入业务域名的状态。

本 Lab 覆盖两种培训场景：当 `auto_create_dnspod_records = true` 时由 Terraform 自动创建 DNSPod 验证记录；当该值为 `false` 时，学员根据 output 手工在外部 DNS 平台添加记录。完成后需要通过 output 和控制台确认验证状态。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：继续管理 Lab 03 创建的 EdgeOne Zone，作为所有权验证的目标站点。
- `tencentcloud_dnspod_record.ownership`：可选资源。启用 `auto_create_dnspod_records` 时自动创建域名所有权验证 DNS 记录；关闭时不创建，仅输出验证信息供手工配置。
- `tencentcloud_teo_ownership_verify.zone`：向 EdgeOne 发起站点域名所有权验证。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 05 只能在 Lab 04 之后执行。

### Lab 05：域名管理

创建 `www` 业务加速域名，并配置源站、回源协议、回源端口和域名在线状态。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：继续管理 EdgeOne Zone，作为加速域名的站点容器。
- `tencentcloud_teo_ownership_verify.zone`：确保站点所有权验证已完成或处于可继续接入的状态。
- `tencentcloud_teo_acceleration_domain.www`：创建 `www` 业务加速域名，配置源站地址、源站类型、Host Header、HTTP/HTTPS 回源端口、回源协议和在线状态。
- `tencentcloud_dnspod_record.ownership`：可选资源。仅在自动 DNSPod 模式下管理所有权验证记录。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 06 只能在 Lab 05 之后执行。

本 Lab 的重点是让学员理解 EdgeOne Zone 和 Acceleration Domain 的关系：Zone 是站点容器，Acceleration Domain 是真正承载业务访问的域名。完成后，学员应能获得 EdgeOne 分配的 CNAME，并为后续 DNS 切流做好准备。

### Lab 06：CNAME 配置

配置或输出业务域名到 EdgeOne CNAME 的解析关系，使用户访问路径能够进入 EdgeOne。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：继续管理 EdgeOne Zone。
- `tencentcloud_teo_acceleration_domain.www`：继续管理 `www` 加速域名，并读取 EdgeOne 分配的 CNAME。
- `tencentcloud_dnspod_record.www_cname`：可选资源。启用 `auto_create_dnspod_records` 时创建业务域名的 CNAME 记录，把 `www` 指向 EdgeOne CNAME；关闭时不创建，仅输出 `edgeone_cname`。
- `tencentcloud_dnspod_record.ownership`：可选资源。自动 DNSPod 模式下继续管理所有权验证记录。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 07 只能在 Lab 06 之后执行。

如果启用 DNSPod 自动化，本 Lab 会创建业务 CNAME 记录；如果使用手工 DNS 模式，本 Lab 会输出准确的 `edgeone_cname` 供学员在 DNS 控制台配置。完成后，学员应能理解 CNAME 生效、DNS 传播和 `dig`/`curl` 验证之间的关系。

### Lab 07：SSL 证书

为 `www` 加速域名启用 HTTPS 证书配置，支持 EdgeOne 免费证书或已有 SSL 证书两种模式。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_zone.zone`：继续管理 EdgeOne Zone。
- `tencentcloud_teo_acceleration_domain.www`：继续管理 `www` 加速域名，作为证书绑定目标。
- `tencentcloud_teo_certificate_config.www`：为 `www` 加速域名配置证书。`certificate_mode = "eofreecert"` 时申请/使用 EdgeOne 免费证书；`certificate_mode = "sslcert"` 时绑定 `ssl_cert_id` 指定的已有证书。
- `tencentcloud_dnspod_record.www_cname`：可选资源。自动 DNSPod 模式下继续管理业务 CNAME 记录。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 08 只能在 Lab 07 之后执行。

本 Lab 的目标不是深入讲解证书生命周期，而是让学员掌握 Terraform 如何把证书模式、证书 ID 和加速域名绑定起来。完成后，学员应能通过 output 核对证书配置 ID、证书模式和受保护的 host。

### Lab 08：规则引擎

创建一条 L7 加速规则，对 `www` 加速域名配置 HTTPS 强制跳转、静态资源缓存和动态页面不缓存。

本 Lab 创建的规则与动作如下：

- `workshop-www-https-cache`：绑定到 `www` 加速域名的 Rule Engine 规则。
- `ForceRedirectHTTPS`：把 HTTP 请求强制跳转到 HTTPS。
- `Cache static assets for 30 days`：匹配静态资源路径，并设置 30 天缓存 TTL。
- `Do not cache dynamic pages`：匹配动态页面路径，并设置 no-cache，避免动态内容被边缘节点缓存。

本 Lab 帮助学员理解 EdgeOne 规则的匹配条件、动作和子规则结构。完成后，学员应能解释该规则如何匹配业务域名、如何对静态资源设置缓存时间，以及为什么动态页面通常需要 no-cache。

### Lab 09：安全策略 Monitor 模式

在 Zone 默认安全策略中添加 Monitor 模式的 Web Security Custom Rule，用于观察可疑请求而不阻断业务流量。

本 Lab 创建或保留的规则与动作如下：

- `workshop-www-https-cache`：沿用 Lab 08 的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源缓存和动态页面 no-cache。
- `monitor-curl-on-login`：新增到 `ZoneDefaultPolicy` 的 Web Security Custom Rule，匹配路径包含 `/login` 且 User-Agent 包含 `curl` 的请求，动作是 `Monitor`，用于观察疑似脚本访问登录入口。

本 Lab 新增规则 `monitor-curl-on-login`，匹配路径包含 `/login` 且 User-Agent 包含 `curl` 的请求，并执行 `Monitor`。完成后，学员应理解 Monitor 模式适合培训、灰度和规则调优阶段，并能通过 output 查看新增规则名称和安全策略实体。

### Lab 10：配置智能Bot

在 Lab 09 的基础上启用 Bot Management 和智能Bot，并为高风险 Bot 请求配置 Monitor 动作。

本 Lab 创建或保留的规则与动作如下：

- `workshop-www-https-cache`：沿用 Lab 08 的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源缓存和动态页面 no-cache。
- `monitor-curl-on-login`：沿用 Lab 09 的 Web Security Custom Rule，继续以 `Monitor` 观察 `/login` + `curl` 请求。
- `bot-monitor-api-curl`：新增到 Bot Management 的 Bot Custom Rule，匹配路径包含 `/api` 且 User-Agent 包含 `curl` 的请求，动作是 `Monitor`。
- Bot Intelligence 分类动作：High Risk Bot 和 Likely Bot 使用 `Monitor`，Verified Bot 和 Human 使用 `Allow`。

本 Lab 同时新增 Bot Custom Rule `bot-monitor-api-curl`，匹配 `/api` + `curl` 的请求并执行 Monitor。完成后，学员应能区分 Web Security Custom Rule 和 Bot Custom Rule，理解 High Risk Bot、Likely Bot、Verified Bot、Human 不同分类的处理动作。

### Lab 11：Web 安全模板 与域名绑定

创建 Web 安全模板，把 Lab 09/10 中的安全能力整理成可复用模板，并绑定到新建的 `www` 加速域名。

本 Lab 创建或保留的规则与动作如下：

- `workshop-www-https-cache`：沿用 Lab 08 的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源缓存和动态页面 no-cache。
- `monitor-curl-on-login`：保留在 `ZoneDefaultPolicy` 中，同时写入 Web 安全模板；匹配 `/login` + `curl` 请求，动作是 `Monitor`。
- `bot-monitor-api-curl`：保留在 `ZoneDefaultPolicy` 中，同时写入 Web 安全模板的 Bot Custom Rule；匹配 `/api` + `curl` 请求，动作是 `Monitor`。
- `monitor-api-curl`：新增到 Web 安全模板的 Custom Rule；匹配 `/api` + `curl` 请求，动作是 `Monitor`。
- `login-single-ip-rate-limit`：新增到 Web 安全模板的 Rate Limiting Rule；匹配 `/login` 请求，按客户端 IP 在 60 秒窗口内统计，阈值 300，命中后以 `Monitor` 观察 30 分钟。
- `health-check-skip-security-modules`：新增到 Web 安全模板的 Exception Rule；匹配 `/healthz`，跳过 Custom Rules、Rate Limiting 和 Bot 模块，避免健康检查被安全规则影响。

本 Lab 的 template 包含 Custom Rule、Bot Custom Rule、智能Bot、Rate Limiting 和 Exception Rule。完成后，学员应理解 Zone Default Policy 和 安全模板的差异，知道如何通过模板把安全策略绑定到指定域名，并能通过 output 核对模板名称、绑定域名和全部规则名称。

### Lab 12：版本管理

为 EdgeOne 站点的 L7 加速配置组启用版本控制模式，导出当前 L7 加速配置，创建一个新的配置组版本，并把该版本同时发布到 Production 和 Staging 环境。

本 Lab 不直接新增即时生效的 Rule Engine 规则，而是把当前 L7 加速配置打包为一个受版本管理的配置组版本。版本内容包含前序 Lab 已创建的 L7 规则：

- `workshop-www-https-cache`：包含 HTTPS 强制跳转、静态资源 30 天缓存和动态页面 no-cache 配置。

安全相关规则仍由 Zone Default Policy 和 Web 安全模板管理，包括 `monitor-curl-on-login`、`bot-monitor-api-curl`、`monitor-api-curl`、`login-single-ip-rate-limit` 和 `health-check-skip-security-modules`。本 Lab 的重点是把 L7 配置版本化，并发布到 Production 和 Staging。

本 Lab 位于 Web 安全模板之后、缓存运维实验之前，用于帮助学员理解 EdgeOne 配置变更的版本化流程：启用版本控制、导出配置、创建版本、发布版本。默认情况下 `enable_version_deploy = true`，Terraform 会自动发现 L7 配置组 ID、Production 环境 ID 和 Staging 环境 ID。

### Lab 13：更新版本

基于 Lab 12 已启用的 EdgeOne Version Management，导出当前 L7 加速配置，生成一个更新后的配置组版本，并把新版本同时发布到 Production 和 Staging 环境。

本 Lab 通过版本管理方式创建或保留的规则与动作如下：

- `workshop-www-https-cache`：保留前序版本中的 Rule Engine 规则，继续负责 HTTPS 强制跳转、静态资源 30 天缓存和动态页面 no-cache。
- `workshop-version-canary-no-cache`：新增到更新版本中的 Rule Engine 规则；匹配 `/version-canary/*` 路径并设置 no-cache，用于演示版本化发布下的灰度验证路径。

本 Lab 不会直接调用即时生效的 L7 Rule API 修改线上规则，而是导出当前 `L7AccelerationConfig`，生成新的配置组版本，再发布到 Staging 和 Production。安全相关规则继续由前序的 Zone Default Policy 和 Web 安全模板管理。

本 Lab 用于演示版本控制模式下的推荐变更流程：不再直接调用即时生效的 L7 Rule API，而是通过导出配置、生成新版本、发布版本来完成配置更新。为了让版本差异更清晰，本 Lab 会把原规则描述更新为 `Managed by Terraform workshop - updated version`，并新增一条 规则引擎规则 `workshop-version-canary-no-cache`。该规则只匹配 `/version-canary/*` 路径并设置不缓存，不改变已有 HTTPS 跳转、静态资源缓存或源站配置。

### Lab 14：Purge Cache

提交 EdgeOne Purge Cache 任务，刷新 `www` 加速域名首页 URL 的缓存。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_purge_task.www_home`：提交 URL 刷新任务，目标为 `https://www.<zone_name>/`，用于让 EdgeOne 节点删除该 URL 的已有缓存。
- `tencentcloud_teo_zone.zone`、`tencentcloud_teo_acceleration_domain.www`、`tencentcloud_teo_certificate_config.www`、安全策略、Web 安全模板和版本管理资源：作为前序 Lab 资源继续纳入配置，保持 state 完整，避免回退执行时丢失管理关系。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 15 只能在 Lab 14 之后执行。

本 Lab 只关注缓存刷新本身，前置 Zone、域名、证书、L7 和安全配置在本目录中作为只读依赖存在，避免重复修改在线资源。完成后，学员应能通过 `purge_job_id`、`purge_type` 和 `purge_targets` 证明刷新任务已提交。

### Lab 15：Prefetch URLs

提交 EdgeOne Prefetch Task，把 `www` 加速域名首页 URL 主动预热到 EdgeOne 节点。

本 Lab 创建或管理的资源如下：

- `tencentcloud_teo_prefetch_task_operation.www_home`：提交 URL 预热任务，目标为 `https://www.<zone_name>/`，用于让 EdgeOne 节点提前从源站拉取内容。
- `tencentcloud_teo_purge_task.www_home`：保留 Lab 14 的刷新任务资源，展示 Purge 与 Prefetch 的连续缓存运维流程。
- `tencentcloud_teo_zone.zone`、`tencentcloud_teo_acceleration_domain.www`、`tencentcloud_teo_certificate_config.www`、安全策略、Web 安全模板和版本管理资源：作为前序 Lab 资源继续纳入配置，保持 state 完整，避免回退执行时丢失管理关系。
- `terraform_data.lab_sequence_guard`：把当前 Lab ID 写入共享 state，确保 Lab 16 可以从 Lab 15 进入清理阶段。

本 Lab 帮助学员理解 Purge 和 Prefetch 的区别：Purge 用于清除已有缓存，Prefetch 用于提前拉取内容。完成后，学员应能通过 `prefetch_job_id`、`prefetch_mode` 和 `prefetch_targets` 确认预热任务已提交。

### Lab 16：资源清理

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
