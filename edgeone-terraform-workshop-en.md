# Tencent Cloud EdgeOne Terraform Workshop

Mapped agenda: 3-day training, 3 hours per day, EdgeOne hands-on focused

## Workshop Goal

This package guides participants through creating and validating a Tencent Cloud EdgeOne onboarding workflow with Terraform. Terraform is kept intentionally lightweight, while the hands-on work focuses on EdgeOne site creation, domain ownership verification, acceleration domain setup, CNAME, HTTPS, L7 rules, security policy, and troubleshooting.

By the end of the workshop, participants should be able to:

- Manage Tencent Cloud CAM credentials through a configuration file.
- Initialize the TencentCloud Terraform Provider.
- Query available EdgeOne plans and confirm `plan_id`.
- Create an EdgeOne site.
- Complete domain ownership verification.
- Create an acceleration domain and configure the origin.
- Configure business CNAME and HTTPS.
- Configure basic L7 acceleration rules.
- Understand security policy management through a Monitor-mode example.
- Complete the full Terraform workflow with plan, apply, state, output, and destroy.
- Configure extended Labs such as Bot Intelligence, Web Security Template, cache purge, and cache prefetch.

## Directory Structure

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

## Lab Goal

### Lab 01: Provider Initialization

Initialize the Terraform execution environment for this workshop and confirm that the TencentCloud provider can be loaded correctly. After this Lab, participants should understand how the Terraform working directory, provider configuration, shared variable files, and shared state fit together.

This Lab does not create cloud resources. Its purpose is to establish a clean execution baseline: `terraform init` downloads the provider, `terraform validate` passes, and `terraform plan` can read the shared configuration successfully.

Objects created or managed by this Lab:

- `terraform_data.lab_sequence_guard`: Writes the current Lab ID for later sequence protection.
- Terraform local backend: Uses `shared/edgeone-workshop.tfstate` as the shared state file for all Labs.
- TencentCloud Provider configuration: Reads CAM credentials from `lab-common/credentials.auto.tfvars` for later EdgeOne API access.
- Cloud resources: none. This Lab does not create EdgeOne, DNSPod, certificate, or security resources.

### Lab 02: Query EdgeOne Plans

Query the EdgeOne plans available to the current account through a Terraform data source, then use the result to confirm the `plan_id` required by later Zone creation Labs.

This Lab still does not create cloud resources. It teaches the difference between read-only data sources and managed resources, introduces `data.tencentcloud_teo_zone_available_plans.available`, and helps participants align the queried plan with `lab-common/terraform.tfvars`.

Objects created or managed by this Lab:

- `data.tencentcloud_teo_zone_available_plans.available`: Read-only query for EdgeOne plans available to the current account, used to confirm `plan_id`.
- `terraform_data.lab_sequence_guard`: Updates the shared state Lab ID to `lab-02-query-plans` so Lab 03 can verify sequence.
- Cloud resources: none. This Lab only queries plans and does not create or modify EdgeOne resources.

### Lab 03: Create EdgeOne Site

Create the EdgeOne Zone that becomes the foundation for ownership verification, acceleration domain creation, HTTPS, L7 rules, and security policy configuration.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Creates the EdgeOne site Zone with `partial` onboarding mode, configured `area`, `plan_id`, `zone_name`, and `alias_zone_name`.
- `data.tencentcloud_teo_zone_available_plans.available`: Read-only query for available plans, used to confirm the configured `plan_id`.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 04 can only run after Lab 03.

After this Lab, participants should be able to cross-check the Zone name, Zone ID, alias, and status in both Terraform outputs and the EdgeOne console, and understand why a newly created Zone usually still requires domain ownership verification.

### Lab 04: Domain Ownership Verification

Complete EdgeOne domain ownership verification so the Zone can continue to the business domain onboarding steps.

This Lab supports two classroom modes: when `auto_create_dnspod_records = true`, Terraform creates the DNSPod verification record; when it is `false`, participants use the output to create the required DNS record in an external DNS platform. The final check is to confirm the verification status from Terraform output and the console.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Continues to manage the EdgeOne Zone created in Lab 03 as the site to verify.
- `tencentcloud_dnspod_record.ownership`: Optional resource. When `auto_create_dnspod_records` is enabled, it creates the DNS ownership verification record; when disabled, no DNSPod record is created and the output is used for manual DNS configuration.
- `tencentcloud_teo_ownership_verify.zone`: Triggers EdgeOne domain ownership verification for the site.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 05 can only run after Lab 04.

### Lab 05: Domain Management

Create the `www` business acceleration domain and configure its origin, origin protocol, origin ports, and online status.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Continues to manage the EdgeOne Zone as the site container for the acceleration domain.
- `tencentcloud_teo_ownership_verify.zone`: Ensures site ownership verification has completed or is ready for business-domain onboarding.
- `tencentcloud_teo_acceleration_domain.www`: Creates the `www` business acceleration domain and configures origin address, origin type, Host Header, HTTP/HTTPS origin ports, origin protocol, and online status.
- `tencentcloud_dnspod_record.ownership`: Optional resource. It manages the ownership verification DNS record only in automated DNSPod mode.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 06 can only run after Lab 05.

The key learning point is the relationship between an EdgeOne Zone and an Acceleration Domain: the Zone is the site container, while the Acceleration Domain is the hostname that receives business traffic. After this Lab, participants should have the EdgeOne CNAME needed for DNS cutover.

### Lab 06: CNAME Setup

Configure or output the DNS CNAME path from the business domain to the EdgeOne CNAME so user traffic can enter EdgeOne.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Continues to manage the EdgeOne Zone.
- `tencentcloud_teo_acceleration_domain.www`: Continues to manage the `www` acceleration domain and reads the EdgeOne-assigned CNAME.
- `tencentcloud_dnspod_record.www_cname`: Optional resource. When `auto_create_dnspod_records` is enabled, it creates the business CNAME record from `www` to the EdgeOne CNAME; when disabled, no DNSPod record is created and `edgeone_cname` is output for manual configuration.
- `tencentcloud_dnspod_record.ownership`: Optional resource. It continues to manage the ownership verification record in automated DNSPod mode.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 07 can only run after Lab 06.

If DNSPod automation is enabled, this Lab creates the business CNAME record. If manual DNS mode is used, it outputs the exact `edgeone_cname` for participants to configure in their DNS console. Participants should understand CNAME propagation and how to validate it with `dig` or `curl`.

### Lab 07: SSL Certificate

Enable HTTPS certificate configuration for the `www` acceleration domain, using either an EdgeOne free certificate or an existing SSL certificate.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Continues to manage the EdgeOne Zone.
- `tencentcloud_teo_acceleration_domain.www`: Continues to manage the `www` acceleration domain as the certificate binding target.
- `tencentcloud_teo_certificate_config.www`: Configures the certificate for the `www` acceleration domain. When `certificate_mode = "eofreecert"`, it requests or uses an EdgeOne free certificate; when `certificate_mode = "sslcert"`, it binds the existing certificate specified by `ssl_cert_id`.
- `tencentcloud_dnspod_record.www_cname`: Optional resource. It continues to manage the business CNAME record in automated DNSPod mode.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 08 can only run after Lab 07.

This Lab does not attempt to cover the full certificate lifecycle. Instead, it focuses on how Terraform binds the certificate mode, optional certificate ID, and acceleration domain together. Participants should verify the certificate configuration ID, certificate mode, and protected host from the outputs.

### Lab 08: Rule Engine

Create an L7 acceleration rule for the `www` acceleration domain, including HTTPS redirect, static asset caching, and dynamic no-cache behavior.

Rules and actions created by this Lab:

- `workshop-www-https-cache`: Rule Engine rule bound to the `www` acceleration domain.
- `ForceRedirectHTTPS`: Redirects HTTP requests to HTTPS.
- `Cache static assets for 30 days`: Matches static asset paths and sets a 30-day cache TTL.
- `Do not cache dynamic pages`: Matches dynamic page paths and sets no-cache so dynamic content is not cached at the edge.

This Lab teaches the structure of EdgeOne rule matching, actions, and sub-rules. Participants should be able to explain how the rule matches the business domain, why static assets receive a long cache TTL, and why dynamic pages are configured as no-cache.

### Lab 09: Security Policy in Monitor Mode

Add a Monitor-mode Web Security Custom Rule to the Zone default security policy so suspicious requests can be observed without blocking production traffic.

Rules and actions created or carried by this Lab:

- `workshop-www-https-cache`: Carries forward the Lab 08 Rule Engine rule for HTTPS redirect, static asset caching, and dynamic no-cache behavior.
- `monitor-curl-on-login`: Adds a Web Security Custom Rule to `ZoneDefaultPolicy`. It matches requests where the path contains `/login` and the User-Agent contains `curl`, then applies `Monitor` to observe suspected scripted login access.

This Lab introduces `monitor-curl-on-login`, which matches requests where the path contains `/login` and the User-Agent contains `curl`, then applies `Monitor`. Participants should understand why Monitor mode is useful for training, rollout, and rule tuning, and should verify the new rule name and policy entity from the outputs.

### Lab 10: Configure Bot Intelligence

Enable Bot Management and Bot Intelligence on top of Lab 09, and configure high-risk bot requests to use the Monitor action.

Rules and actions created or carried by this Lab:

- `workshop-www-https-cache`: Carries forward the Lab 08 Rule Engine rule for HTTPS redirect, static asset caching, and dynamic no-cache behavior.
- `monitor-curl-on-login`: Carries forward the Lab 09 Web Security Custom Rule and continues to monitor `/login` + `curl` requests.
- `bot-monitor-api-curl`: Adds a Bot Custom Rule under Bot Management. It matches requests where the path contains `/api` and the User-Agent contains `curl`, then applies `Monitor`.
- Bot Intelligence category actions: High Risk Bot and Likely Bot use `Monitor`; Verified Bot and Human use `Allow`.

This Lab also adds the Bot Custom Rule `bot-monitor-api-curl`, matching `/api` + `curl` requests with Monitor. Participants should distinguish Web Security Custom Rules from Bot Custom Rules and understand the configured actions for High Risk Bot, Likely Bot, Verified Bot, and Human traffic.

### Lab 11: Web Security Template and Domain Binding

Create a Web Security Template, organize the Lab 09/10 security capabilities into a reusable template, and bind it to the newly created `www` acceleration domain.

Rules and actions created or carried by this Lab:

- `workshop-www-https-cache`: Carries forward the Lab 08 Rule Engine rule for HTTPS redirect, static asset caching, and dynamic no-cache behavior.
- `monitor-curl-on-login`: Remains in `ZoneDefaultPolicy` and is also added to the Web Security Template. It matches `/login` + `curl` requests and applies `Monitor`.
- `bot-monitor-api-curl`: Remains in `ZoneDefaultPolicy` and is also added as a Bot Custom Rule in the Web Security Template. It matches `/api` + `curl` requests and applies `Monitor`.
- `monitor-api-curl`: Adds a Web Security Template Custom Rule. It matches `/api` + `curl` requests and applies `Monitor`.
- `login-single-ip-rate-limit`: Adds a Web Security Template Rate Limiting Rule. It matches `/login` requests, counts by client IP in a 60-second window, uses a threshold of 300, and monitors matching traffic for 30 minutes.
- `health-check-skip-security-modules`: Adds a Web Security Template Exception Rule. It matches `/healthz` and skips Custom Rules, Rate Limiting, and Bot modules so health checks are not affected by security rules.

The template includes Web Security Custom Rules, a Bot Custom Rule, Bot Intelligence, Rate Limiting, and an Exception Rule. Participants should understand the difference between Zone Default Policy and Security Template, how a template is bound to a specific domain, and how to verify the template name, bound domain, and all rule names from the outputs.

### Lab 12: Version Management

Enable version control mode for the EdgeOne L7 acceleration configuration group, export the current L7 acceleration configuration, create a new configuration group version, and deploy that version to both Production and Staging.

This Lab does not directly add a new immediate-effect Rule Engine rule. Instead, it packages the current L7 acceleration configuration into a version-managed configuration group version. The version content includes the L7 rule created by previous Labs:

- `workshop-www-https-cache`: Includes HTTPS redirect, 30-day static asset caching, and dynamic no-cache behavior.

Security rules continue to be managed by Zone Default Policy and the Web Security Template, including `monitor-curl-on-login`, `bot-monitor-api-curl`, `monitor-api-curl`, `login-single-ip-rate-limit`, and `health-check-skip-security-modules`. The focus of this Lab is to version and deploy the L7 configuration to Production and Staging.

This Lab sits after the Web Security Template Lab and before the cache operations Labs. It helps participants understand the versioned EdgeOne configuration workflow: enable version control, export configuration, create a version, and deploy the version. By default, `enable_version_deploy = true`, and Terraform automatically discovers the L7 configuration group ID, Production environment ID, and Staging environment ID.

### Lab 13: Update Version

Use the EdgeOne Version Management mode enabled in Lab 12, export the current L7 acceleration configuration, generate an updated configuration group version, and deploy the new version to both Production and Staging.

Rules and actions created or carried by this Lab through Version Management:

- `workshop-www-https-cache`: Carries forward the Rule Engine rule from the previous version for HTTPS redirect, 30-day static asset caching, and dynamic no-cache behavior.
- `workshop-version-canary-no-cache`: Adds a Rule Engine rule to the updated version. It matches `/version-canary/*` and sets no-cache, providing a canary validation path for the versioned deployment workflow.

This Lab does not directly call the immediate-effect L7 Rule API to modify online rules. It exports the current `L7AccelerationConfig`, generates a new configuration group version, and deploys it to Staging and Production. Security rules remain managed by the earlier Zone Default Policy and Web Security Template.

This Lab demonstrates the recommended change workflow in version control mode: do not call the immediate-effect L7 Rule API directly. Instead, export the configuration, create a new version, and deploy that version. To make the version difference easier to see, this Lab updates the original rule description to `Managed by Terraform workshop - updated version` and adds a Rule Engine rule named `workshop-version-canary-no-cache`. The new rule only matches `/version-canary/*` and disables cache for that path, without changing the existing HTTPS redirect, static asset cache policy, or origin settings.

### Lab 14: Purge Cache

Submit an EdgeOne Purge Cache task for the home URL of the `www` acceleration domain.

Resources created or managed by this Lab:

- `tencentcloud_teo_purge_task.www_home`: Submits a URL purge task for `https://www.<zone_name>/`, asking EdgeOne nodes to remove the existing cached object for that URL.
- `tencentcloud_teo_zone.zone`, `tencentcloud_teo_acceleration_domain.www`, `tencentcloud_teo_certificate_config.www`, security policy, Web Security Template, and version-management resources: Kept in the configuration as previous Lab resources so shared state remains complete and management relationships are not dropped.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 15 can only run after Lab 14.

This Lab focuses only on cache purge. Earlier Zone, domain, certificate, L7, and security resources are kept as read-only dependencies in this directory to avoid reconfiguring online resources. Participants should use `purge_job_id`, `purge_type`, and `purge_targets` to prove that the purge task was submitted.

### Lab 15: Prefetch URLs

Submit an EdgeOne Prefetch Task for the home URL of the `www` acceleration domain.

Resources created or managed by this Lab:

- `tencentcloud_teo_prefetch_task_operation.www_home`: Submits a URL prefetch task for `https://www.<zone_name>/`, asking EdgeOne nodes to pull the object from origin in advance.
- `tencentcloud_teo_purge_task.www_home`: Keeps the Lab 14 purge task resource, showing the continuous cache-operations flow from Purge to Prefetch.
- `tencentcloud_teo_zone.zone`, `tencentcloud_teo_acceleration_domain.www`, `tencentcloud_teo_certificate_config.www`, security policy, Web Security Template, and version-management resources: Kept in the configuration as previous Lab resources so shared state remains complete and management relationships are not dropped.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 16 can enter cleanup from Lab 15.

This Lab clarifies the difference between Purge and Prefetch: Purge removes cached content, while Prefetch proactively pulls content to EdgeOne nodes. Participants should confirm the submitted task using `prefetch_job_id`, `prefetch_mode`, and `prefetch_targets`.

### Lab 16: Resource Cleanup

Use `terraform destroy` to clean up the EdgeOne, DNSPod, Security Template, cache task, and related workshop resources managed by Terraform, then verify that shared state is empty.

This Lab can be run after any completed Lab to destroy the workshop resources that have already been created or managed in the current shared state. Cleanup targets include:

- `tencentcloud_teo_prefetch_task_operation.www_home`: Removes Terraform management for the URL prefetch task.
- `tencentcloud_teo_purge_task.www_home`: Removes Terraform management for the URL purge task.
- `tencentcloud_teo_deploy_config_group_version.*`: Cleans up version deployment records for the initial and updated versions across Staging, Production, or a custom environment.
- `tencentcloud_teo_config_group_version.*`: Cleans up L7 configuration group versions created by Version Management.
- `tencentcloud_teo_bind_security_template.www`: Unbinds the Web Security Template from the `www` acceleration domain.
- `tencentcloud_teo_web_security_template.workshop`: Deletes the Web Security Template `workshop_www_security`, including its Custom Rule, Bot Custom Rule, Rate Limiting, and Exception Rule configuration.
- `tencentcloud_teo_security_policy_config.zone_default`: Cleans up workshop-managed Monitor rules and Bot Intelligence configuration in the Zone default security policy.
- `tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache`: Deletes the Rule Engine rule `workshop-www-https-cache`.
- `tencentcloud_teo_certificate_config.www`: Deletes the certificate configuration for the `www` acceleration domain.
- `tencentcloud_dnspod_record.www_cname`: Optional resource. In automated DNSPod mode, deletes the business CNAME record.
- `tencentcloud_teo_acceleration_domain.www`: Deletes the `www` business acceleration domain.
- `tencentcloud_teo_ownership_verify.zone` and `tencentcloud_dnspod_record.ownership`: Clean up the ownership verification resource and optional DNSPod verification record.
- `tencentcloud_teo_zone.zone`: Deletes the EdgeOne Zone.
- `terraform_data.lab_sequence_guard`: Deletes the local sequence guard record.

This Lab closes the full workflow: create, verify, change, output, and clean up. Participants should understand which resources Terraform destroys automatically, which manual DNS records must be removed in an external console, and how to validate cleanup with `terraform state list`.

Notes:

- `labs/lab-xx-*/terraform/` contains staged classroom code. Each Lab only includes Terraform configuration required for that stage.
- `labs/lab-common/` stores `terraform.tfvars` and `credentials.auto.tfvars` shared by all Labs.
- Each Lab explicitly reads the shared configuration with `-var-file=../../lab-common/...`.
- All Lab directories share `shared/edgeone-workshop.tfstate` through a local backend, so they can be run sequentially.
- `shared/` is the shared Terraform state directory. `edgeone-workshop.tfstate` is generated at runtime and excluded from the delivery package.
- For formal training, participants should use the staged Labs under `labs/lab-xx-*/terraform/`.
- After Lab 12 enables Version Management, Lab 01 through Lab 11 refuse to run. This avoids changing earlier immediate-effect configuration while the site is in `version_control` mode. To restart, run Lab 16 to clean up resources and shared state first.
- Lab 16 is a destroy-only cleanup Lab. It can be run after any completed Lab to clean up resources already created and recorded in the shared state; it must be run with `terraform plan -destroy` and `terraform destroy` plus `cleanup_confirm_destroy=true`. Normal `terraform apply` does not delete resources.
- Some Lab `terraform/removed.tf` files keep compatibility with state records left by later Labs. Terraform only forgets those records from state and does not destroy cloud resources. Seeing “will no longer be managed by Terraform, but will not be destroyed” is an expected state compatibility notice; actual execution is still controlled by the sequence guard.

## Workshop Run Rules

- Before starting Lab 01, go to `labs/lab-01-provider-init/terraform` and run `./reset-shared-state.sh` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.
- Each README uses native Terraform commands: `terraform plan/apply/destroy`. Sequence protection is enforced by each Lab's `sequence_guard.tf`.

## Credential Configuration

This workshop uses a local credential configuration file. Participants copy the example file:

```bash
cd labs/lab-common
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Then fill in:

```hcl
tencentcloud_secret_id  = "REPLACE_WITH_TENCENTCLOUD_SECRET_ID"
tencentcloud_secret_key = "REPLACE_WITH_TENCENTCLOUD_SECRET_KEY"
```

Security requirements:

- Do not commit `credentials.auto.tfvars`.
- Do not expose real keys in screenshots, recordings, or chat tools.
- Disable or delete temporary CAM keys after training.
- For production, prefer CI/CD secrets, temporary credentials, role-based access, or OIDC.

## Terraform Execution Path

Each Lab has its own working directory. For example:

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

When moving to the next Lab, switch to the next directory:

```bash
cd ../../lab-04-ownership-verify/terraform
terraform init
```

## Real Execution Requirements

```text
1. Valid Tencent Cloud CAM credentials.
2. CAM permissions for EdgeOne, SSL Certificate, and DNSPod where needed.
3. An available EdgeOne plan_id.
4. A controlled test domain.
5. Ability to create DNS verification records.
6. A publicly reachable origin.
7. Ability to point the business CNAME to the EdgeOne CNAME.
```

## Expected Results

Example Terraform outputs:

```text
zone_id = "zone-xxxxxx"
acceleration_domain = "www.example.com"
edgeone_cname = "www.example.com.eo.dnse0.com"
```

DNS validation:

```bash
dig +short CNAME www.example.com
```

Expected result:

```text
www.example.com.eo.dnse0.com.
```

Access validation:

```bash
curl -I http://www.example.com
curl -I https://www.example.com
```

HTTP should show EdgeOne response headers, such as:

```text
Server: TencentEdgeOne
```

The HTTPS status code depends on certificate readiness, origin protocol, and origin availability.

## Delivery Note

Use the following zip for formal delivery:

```text
outputs/edgeone-terraform-workshop.zip
```

The delivery zip should not contain real credentials, real `terraform.tfvars`, state backups, or the `.terraform/` directory. `shared/edgeone-workshop.tfstate` is kept as an empty initial state for the sequential Workshop flow.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
