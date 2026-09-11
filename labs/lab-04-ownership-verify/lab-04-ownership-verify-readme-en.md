# Lab 04: Domain Ownership Verification

Lab directory: `lab-04-ownership-verify`

## Goal

Complete EdgeOne domain ownership verification so the Zone can continue to the business domain onboarding steps.

This Lab supports two classroom modes: when `auto_create_dnspod_records = true`, Terraform creates the DNSPod verification record; when it is `false`, participants use the output to create the required DNS record in an external DNS platform. The final check is to confirm the verification status from Terraform output and the console.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Continues to manage the EdgeOne Zone created in Lab 03 as the site to verify.
- `tencentcloud_dnspod_record.ownership`: Optional resource. When `auto_create_dnspod_records` is enabled, it creates the DNS ownership verification record; when disabled, no DNSPod record is created and the output is used for manual DNS configuration.
- `tencentcloud_teo_ownership_verify.zone`: Triggers EdgeOne domain ownership verification for the site.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 05 can only run after Lab 04.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-04-ownership-verify/terraform
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
cd ../lab-04-ownership-verify/terraform
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

- Complete Terraform output list: `lab_id`, `zone_id`, `ownership_verify_status`, `ownership_verification`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `zone_id`: EdgeOne Zone/Site ID.
- `ownership_verify_status`: Domain ownership verification result.
- `ownership_verification`: DNS ownership verification information.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-05-domain-management`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform manages `tencentcloud_teo_ownership_verify.zone`.
- `ownership_verify_status` is `success`.
- Any required manual DNS verification records have been created outside Terraform when DNSPod automation is disabled.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
