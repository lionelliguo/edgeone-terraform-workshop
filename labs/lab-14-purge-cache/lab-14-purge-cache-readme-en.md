# Lab 14: Purge Cache

Lab directory: `lab-14-purge-cache`

## Goal

Submit an EdgeOne Purge Cache task for the home URL of the `www` acceleration domain.

Resources created or managed by this Lab:

- `tencentcloud_teo_purge_task.www_home`: Submits a URL purge task for `https://www.<zone_name>/`, asking EdgeOne nodes to remove the existing cached object for that URL.
- `tencentcloud_teo_zone.zone`, `tencentcloud_teo_acceleration_domain.www`, `tencentcloud_teo_certificate_config.www`, security policy, Web Security Template, and version-management resources: Kept in the configuration as previous Lab resources so shared state remains complete and management relationships are not dropped.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 15 can only run after Lab 14.

This Lab focuses only on cache purge. Earlier Zone, domain, certificate, L7, and security resources are kept as read-only dependencies in this directory to avoid reconfiguring online resources. Participants should use `purge_job_id`, `purge_type`, and `purge_targets` to prove that the purge task was submitted.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-14-purge-cache/terraform
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
cd ../lab-14-purge-cache/terraform
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

- Complete Terraform output list: `lab_id`, `purge_type`, `purge_job_id`, `purge_targets`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `purge_type`: Cache purge type.
- `purge_job_id`: Cache purge task job ID.
- `purge_targets`: Cache purge target URL list.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-15-prefetch-urls`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform creates `tencentcloud_teo_purge_task.www_home`.
- `purge_job_id` is populated.
- `purge_targets` points to the current `www` acceleration domain.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
