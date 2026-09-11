# Lab 09: Security Policy in Monitor Mode

Lab directory: `lab-09-security-policy`

## Goal

Add a Monitor-mode Web Security Custom Rule to the Zone default security policy so suspicious requests can be observed without blocking production traffic.

Rules and actions created or carried by this Lab:

- `workshop-www-https-cache`: Carries forward the Lab 08 Rule Engine rule for HTTPS redirect, static asset caching, and dynamic no-cache behavior.
- `monitor-curl-on-login`: Adds a Web Security Custom Rule to `ZoneDefaultPolicy`. It matches requests where the path contains `/login` and the User-Agent contains `curl`, then applies `Monitor` to observe suspected scripted login access.

This Lab introduces `monitor-curl-on-login`, which matches requests where the path contains `/login` and the User-Agent contains `curl`, then applies `Monitor`. Participants should understand why Monitor mode is useful for training, rollout, and rule tuning, and should verify the new rule name and policy entity from the outputs.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-09-security-policy/terraform
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
cd ../lab-09-security-policy/terraform
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

- Complete Terraform output list: `lab_id`, `security_policy_enabled`, `security_policy_id`, `security_policy_entity`, `lab_success`, `security_custom_rule_names`, `new_rule_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `security_policy_enabled`: Whether security policy configuration is enabled.
- `security_policy_id`: Security policy configuration ID.
- `security_policy_entity`: Security policy entity name.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `security_custom_rule_names`: Security Custom Rule name list.
- `new_rule_names`: Rule names introduced or managed by this Lab.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-10-bot-intelligence`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- If `enable_security_policy = true`, Terraform manages `tencentcloud_teo_security_policy_config.zone_default`.
- `security_policy_id` is populated when the policy is enabled.
- If `enable_security_policy = false`, the Lab completes without creating a security policy and outputs `null` for policy resource fields.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
