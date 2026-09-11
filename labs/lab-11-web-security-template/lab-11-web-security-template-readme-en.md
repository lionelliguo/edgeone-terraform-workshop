# Lab 11: Web Security Template and Domain Binding

Lab directory: `lab-11-web-security-template`

## Goal

Create a Web Security Template, organize the Lab 09/10 security capabilities into a reusable template, and bind it to the newly created `www` acceleration domain.

Rules and actions created or carried by this Lab:

- `workshop-www-https-cache`: Carries forward the Lab 08 Rule Engine rule for HTTPS redirect, static asset caching, and dynamic no-cache behavior.
- `monitor-curl-on-login`: Remains in `ZoneDefaultPolicy` and is also added to the Web Security Template. It matches `/login` + `curl` requests and applies `Monitor`.
- `bot-monitor-api-curl`: Remains in `ZoneDefaultPolicy` and is also added as a Bot Custom Rule in the Web Security Template. It matches `/api` + `curl` requests and applies `Monitor`.
- `monitor-api-curl`: Adds a Web Security Template Custom Rule. It matches `/api` + `curl` requests and applies `Monitor`.
- `login-single-ip-rate-limit`: Adds a Web Security Template Rate Limiting Rule. It matches `/login` requests, counts by client IP in a 60-second window, uses a threshold of 300, and monitors matching traffic for 30 minutes.
- `health-check-skip-security-modules`: Adds a Web Security Template Exception Rule. It matches `/healthz` and skips Custom Rules, Rate Limiting, and Bot modules so health checks are not affected by security rules.

The template includes Web Security Custom Rules, a Bot Custom Rule, Bot Intelligence, Rate Limiting, and an Exception Rule. Participants should understand the difference between Zone Default Policy and Security Template, how a template is bound to a specific domain, and how to verify the template name, bound domain, and all rule names from the outputs.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-11-web-security-template/terraform
```

## Prepare Variables

All Labs share the same configuration files. Configure them once before the first Lab:

```bash
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Edit `labs/lab-common/terraform.tfvars` and `labs/lab-common/credentials.auto.tfvars` with your test domain, plan_id, origin, and CAM credentials. This Lab explicitly reads the shared configuration with `-var-file=../../lab-common/...`.


## Commands

Switch back to this Lab Terraform directory:

```bash
cd ../lab-11-web-security-template/terraform
```

```bash
# Initialize this Lab backend and the TencentCloud Provider.
terraform init
# Format the Terraform configuration files in this directory.
terraform fmt
# Validate Terraform syntax and provider schema usage.
terraform validate
# Preview the Terraform changes for this Lab without modifying cloud resources.
terraform plan -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

If the plan matches expectations, run:

Deployment usually takes about 5 minutes. Seeing `Still creating...` or `Still modifying...` during this period is expected; keep waiting.

```bash
# Apply this Lab changes and write the result to the shared state.
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

## Expected Outputs

- Complete Terraform output list: `lab_id`, `web_security_template_enabled`, `web_security_template_id`, `web_security_template_name`, `web_security_template_bind_status`, `security_template_domain`, `lab_success`, `security_custom_rule_names`, `bot_custom_rule_names`, `rate_limiting_rule_names`, `exception_rule_names`, `new_rule_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `web_security_template_enabled`: Whether Web Security Template is enabled.
- `web_security_template_id`: Web Security Template ID.
- `web_security_template_name`: Web Security Template name.
- `web_security_template_bind_status`: Security Template binding status.
- `security_template_domain`: Acceleration domain bound to the Security Template.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `security_custom_rule_names`: Security Custom Rule name list.
- `bot_custom_rule_names`: Bot Custom Rule name list.
- `rate_limiting_rule_names`: Rate Limiting rule name list.
- `exception_rule_names`: Exception Rule name list.
- `new_rule_names`: Rule names introduced or managed by this Lab.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-12-version-management`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform creates `tencentcloud_teo_web_security_template.workshop`.
- Terraform creates `tencentcloud_teo_bind_security_template.www`.
- The template contains `monitor-curl-on-login`, `bot-monitor-api-curl`, Bot Intelligence, Rate Limiting, and Exception Rule.
- `security_template_domain` matches the current `www` acceleration domain.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
