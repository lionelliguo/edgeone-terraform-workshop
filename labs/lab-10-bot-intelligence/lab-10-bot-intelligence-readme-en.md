# Lab 10: Configure Bot Intelligence

Lab directory: `lab-10-bot-intelligence`

## Goal

Enable Bot Management and Bot Intelligence on top of Lab 09, and configure high-risk bot requests to use the Monitor action.

Rules and actions created or carried by this Lab:

- `workshop-www-https-cache`: Carries forward the Lab 08 Rule Engine rule for HTTPS redirect, static asset caching, and dynamic no-cache behavior.
- `monitor-curl-on-login`: Carries forward the Lab 09 Web Security Custom Rule and continues to monitor `/login` + `curl` requests.
- `bot-monitor-api-curl`: Adds a Bot Custom Rule under Bot Management. It matches requests where the path contains `/api` and the User-Agent contains `curl`, then applies `Monitor`.
- Bot Intelligence category actions: High Risk Bot and Likely Bot use `Monitor`; Verified Bot and Human use `Allow`.

This Lab also adds the Bot Custom Rule `bot-monitor-api-curl`, matching `/api` + `curl` requests with Monitor. Participants should distinguish Web Security Custom Rules from Bot Custom Rules and understand the configured actions for High Risk Bot, Likely Bot, Verified Bot, and Human traffic.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-10-bot-intelligence/terraform
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
cd ../lab-10-bot-intelligence/terraform
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

- Complete Terraform output list: `lab_id`, `bot_intelligence_enabled`, `security_policy_id`, `bot_high_risk_action`, `bot_custom_rule_name`, `lab_success`, `security_custom_rule_names`, `bot_custom_rule_names`, `new_rule_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `bot_intelligence_enabled`: Whether Bot Intelligence configuration is enabled.
- `security_policy_id`: Security policy configuration ID.
- `bot_high_risk_action`: Action for high-risk bot requests.
- `bot_custom_rule_name`: Bot Custom Rule name.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `security_custom_rule_names`: Security Custom Rule name list.
- `bot_custom_rule_names`: Bot Custom Rule name list.
- `new_rule_names`: Rule names introduced or managed by this Lab.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-11-web-security-template`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform manages `tencentcloud_teo_security_policy_config.zone_default`.
- `security_policy_id` is populated.
- `bot_high_risk_action` outputs `Monitor`.
- Bot Management includes the `bot-monitor-api-curl` custom rule, matching `/api` + `curl` and using Monitor.
- After the first successful run, repeated `terraform plan` or `terraform apply` should show `No changes`; default empty Bot settings returned by the EdgeOne API should not trigger a second update.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
