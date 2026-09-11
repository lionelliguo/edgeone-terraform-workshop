# Tencent Cloud EdgeOne Terraform Workshop

3-Day Training Agenda: 3 Hours per Day, EdgeOne Hands-on Focus  
Version date: 2026-08-01

## Positioning

This agenda is aligned with the current 16 Labs under the `labs/` directory. It is split into 3 days, 3 hours per day, for a total of 9 hours. This version has a lighter pace and is suitable for half-day sessions, online delivery, or internal workshops spread across three consecutive days.

Terraform coverage remains lightweight. The course only covers the Terraform concepts required for the Labs: provider, resource, data source, state, plan/apply/destroy, credential file configuration, shared state, sequence protection, and destroy-only cleanup. Most of the time is reserved for EdgeOne onboarding, domain verification, acceleration domain setup, CNAME, SSL certificate, Rule Engine, security policies, Bot Intelligence, Web Security Template, version management, cache operations, and troubleshooting.

Every Lab uses the current Terraform `outputs.tf` as the source of truth and outputs `execution_steps`, `current_execution`, `created_resource_names`, `lab_id`, `lab_success`, `next_lab`, and `workshop_result`. `execution_steps` lists the resources created, modified, or destroyed step by step, including resource names, key IDs, rule names, actions, target URLs, version numbers, and deployment records. `workshop_result` is the final summary and always includes `lab_id`, `lab_success`, and `next_lab`.

## Training Objectives

By the end of the training, participants should be able to:

- Initialize the TencentCloud Provider with Terraform.
- Manage training credentials through configuration files.
- Use directory-based Labs and shared state to progress through the workshop in order.
- Use `execution_steps` and `current_execution` outputs to identify each Lab's current action, resource names, rule names, and next step.
- Create an EdgeOne Site with Terraform.
- Complete domain ownership verification.
- Create an EdgeOne acceleration domain and configure the origin.
- Configure CNAME Setup and SSL certificate.
- Configure Rule Engine for HTTPS redirect, cache behavior, and version update rules.
- Understand how EdgeOne Security Policy, Bot Intelligence, and Web Security Template can be managed with Terraform.
- Enable version management, create the initial configuration group version, update the version, and deploy versions to both Production and Staging.
- Run Purge Cache, Prefetch URLs, and destroy-only Resource Cleanup.
- Troubleshoot common onboarding, version deployment, cache task, and cleanup issues.

## Prerequisites

Participants should prepare:

- Tencent Cloud account.
- CAM SecretId / SecretKey.
- Available EdgeOne plan ID, `plan_id`.
- A test domain, such as `example.com`.
- A test subdomain, such as `www.example.com`.
- DNS management permissions, either in DNSPod or another DNS provider.
- A publicly reachable origin, such as an origin IP or origin domain.
- Terraform, `curl`, and `dig` installed locally.

## Day 1: `lab-01-provider-init` to `lab-07-ssl-certificate`, Terraform Basics, Site Onboarding, and HTTPS

| Time | Topic | Details |
|---|---|---|
| 09:30-09:45 | Opening and Lab Objectives | Training goals, lab architecture, account/domain/origin checks |
| 09:45-10:05 | EdgeOne and Minimum Terraform Essentials | Site, acceleration domain, origin, CNAME, HTTPS, provider, resource, data source, state |
| 10:05-10:25 | `lab-01-provider-init` | Initialize the Provider, local backend, and `terraform_data.lab_sequence_guard`; no cloud resources are created; output `lab_id`, `lab_success`, `next_lab`, and `workshop_result` |
| 10:25-10:40 | `lab-02-query-plans` | Use read-only data source `tencentcloud_teo_zone_available_plans` to query plans and confirm `plan_id`; no cloud resources are created |
| 10:40-10:50 | Break |  |
| 10:50-11:15 | `lab-03-create-site` | Use `tencentcloud_teo_zone` to create the EdgeOne Site/Zone with `zone_name`, `alias_zone_name`, `area`, and `plan_id` |
| 11:15-11:35 | `lab-04-ownership-verify` | Use `tencentcloud_teo_ownership_verify` for ownership verification; optionally create `tencentcloud_dnspod_record.ownership` |
| 11:35-11:55 | `lab-05-domain-management` | Use `tencentcloud_teo_acceleration_domain` to create the `www` acceleration domain and configure origin, Host Header, origin ports, origin protocol, and online status |
| 11:55-12:10 | `lab-06-cname-setup` | Optionally create `tencentcloud_dnspod_record.www_cname`; in manual DNS mode, output the EdgeOne CNAME and validate with `dig` |
| 12:10-12:30 | `lab-07-ssl-certificate` | Use `tencentcloud_teo_certificate_config` to configure an EdgeOne free certificate or existing SSL certificate for `www`, then validate HTTPS |

## Day 2: `lab-08-rule-engine` to `lab-11-web-security-template`, Rule Engine, Security Policy, Bot, and Security Template

| Time | Topic | Details |
|---|---|---|
| 09:30-09:45 | Day 1 Review | Check shared state, `lab_id` sequence protection, CNAME, HTTPS, and acceleration domain status |
| 09:45-10:15 | Rule Engine Design | Match conditions, actions, HTTPS redirect, cache strategy, and dynamic no-cache |
| 10:15-10:50 | `lab-08-rule-engine` | Use `tencentcloud_teo_l7_acc_rule_v2` to create `workshop-www-https-cache` with HTTPS redirect, 30-day static asset caching, and dynamic no-cache behavior |
| 10:50-11:00 | Break |  |
| 11:00-11:30 | `lab-09-security-policy` | Use `tencentcloud_teo_security_policy_config` to configure the Monitor-mode Custom Rule `monitor-curl-on-login` |
| 11:30-12:00 | `lab-10-bot-intelligence` | Enable Bot Management and Bot Intelligence; add Bot Custom Rule `bot-monitor-api-curl`; High Risk/Likely Bot use Monitor and Verified Bot/Human use Allow |
| 12:00-12:25 | `lab-11-web-security-template` | Create and bind `workshop_www_security`; include `monitor-curl-on-login`, `monitor-api-curl`, `bot-monitor-api-curl`, `login-single-ip-rate-limit`, and `health-check-skip-security-modules` |
| 12:25-12:30 | Day 2 Wrap-up | Review Rule Engine, ZoneDefaultPolicy, Bot Management, Web Security Template resource names, rule names, and standardized outputs |

## Day 3: `lab-12-version-management` to `lab-16-resource-cleanup`, Version Management, Cache Operations, and Cleanup

| Time | Topic | Details |
|---|---|---|
| 09:30-09:45 | Day 2 Review | Check Rule Engine, Security Policy, Bot, and Security Template binding status |
| 09:45-10:25 | `lab-12-version-management` | Enable L7 Version Management, create `tencentcloud_teo_config_group_version.workshop_l7`, and deploy the configuration containing `workshop-www-https-cache` to Production and Staging |
| 10:25-10:35 | Break |  |
| 10:35-11:15 | `lab-13-update-version` | Create an updated version, add Rule Engine rule `workshop-version-canary-no-cache` for `/version-canary/*` with no-cache, and deploy to Production and Staging |
| 11:15-11:35 | `lab-14-purge-cache` | Use `tencentcloud_teo_purge_task.www_home` to purge `https://www.<zone_name>/`, then output `purge_job_id` and `purge_targets` |
| 11:35-11:55 | `lab-15-prefetch-urls` | Use `tencentcloud_teo_prefetch_task_operation.www_home` to prefetch `https://www.<zone_name>/`, then output `prefetch_job_id`, `prefetch_targets`, and `prefetch_mode` |
| 11:55-12:20 | `lab-16-resource-cleanup` | Can be entered after any completed Lab; use `cleanup_confirm_destroy=true` for destroy-only cleanup of Site, domain, certificate, rules, security policy, template, versions, cache tasks, and optional DNSPod records |
| 12:20-12:30 | Final Review | Review sequence protection, post-version-management backward-run blocking, destroy-only cleanup, idempotency, and common troubleshooting paths |

## Time Allocation Notes

- Day 1 covers `lab-01-provider-init` to `lab-07-ssl-certificate`: Terraform initialization, plan query, Site creation, ownership verification, acceleration domain, CNAME, and SSL certificate.
- Day 2 covers `lab-08-rule-engine` to `lab-11-web-security-template`: Rule Engine, Security Policy, Bot Intelligence, and Web Security Template.
- Day 3 covers `lab-12-version-management` to `lab-16-resource-cleanup`: Version Management, Update Version, Purge Cache, Prefetch URLs, and destroy-only Resource Cleanup.

## Final Delivery Checklist

By the end of the training, participants should complete:

- Terraform project initialization.
- Credential configuration file setup.
- `lab_id` sequence protection validation.
- Standard output validation for `execution_steps`, `current_execution`, `next_lab`, and `workshop_result`.
- EdgeOne plan query.
- EdgeOne Site creation.
- Domain ownership verification.
- Acceleration domain creation.
- Origin configuration.
- CNAME configuration.
- SSL certificate configuration.
- Rule Engine rule `workshop-www-https-cache` configuration.
- Monitor-mode Security Policy example `monitor-curl-on-login`.
- Bot Intelligence configuration and Bot Custom Rule `bot-monitor-api-curl`.
- Web Security Template `workshop_www_security` creation and binding, including `monitor-api-curl`, `login-single-ip-rate-limit`, and `health-check-skip-security-modules`.
- Configuration group version management, version update, and version deployment to Production and Staging.
- Lab 13 updated version adds Rule Engine rule `workshop-version-canary-no-cache`.
- Purge Cache with `tencentcloud_teo_purge_task.www_home`.
- Prefetch URLs with `tencentcloud_teo_prefetch_task_operation.www_home`.
- Destroy-only Lab resource cleanup with `cleanup_confirm_destroy=true`, and shared state verified empty.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
