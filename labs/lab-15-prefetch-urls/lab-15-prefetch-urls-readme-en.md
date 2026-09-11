# Lab 15: Prefetch URLs

Lab directory: `lab-15-prefetch-urls`

## Goal

Submit an EdgeOne Prefetch Task for the home URL of the `www` acceleration domain.

Resources created or managed by this Lab:

- `tencentcloud_teo_prefetch_task_operation.www_home`: Submits a URL prefetch task for `https://www.<zone_name>/`, asking EdgeOne nodes to pull the object from origin in advance.
- `tencentcloud_teo_purge_task.www_home`: Keeps the Lab 14 purge task resource, showing the continuous cache-operations flow from Purge to Prefetch.
- `tencentcloud_teo_zone.zone`, `tencentcloud_teo_acceleration_domain.www`, `tencentcloud_teo_certificate_config.www`, security policy, Web Security Template, and version-management resources: Kept in the configuration as previous Lab resources so shared state remains complete and management relationships are not dropped.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 16 can enter cleanup from Lab 15.

This Lab clarifies the difference between Purge and Prefetch: Purge removes cached content, while Prefetch proactively pulls content to EdgeOne nodes. Participants should confirm the submitted task using `prefetch_job_id`, `prefetch_mode`, and `prefetch_targets`.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-15-prefetch-urls/terraform
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
cd ../lab-15-prefetch-urls/terraform
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

- Complete Terraform output list: `lab_id`, `prefetch_job_id`, `prefetch_targets`, `prefetch_mode`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `prefetch_job_id`: Cache prefetch task job ID.
- `prefetch_targets`: Cache prefetch target URL list.
- `prefetch_mode`: Cache prefetch mode.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-16-resource-cleanup`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform creates `tencentcloud_teo_prefetch_task_operation.www_home`.
- `prefetch_job_id` is populated.
- `prefetch_targets` points to the current `www` acceleration domain.
- After the first successful run, repeated `terraform plan` or `terraform apply` should show `No changes` and should not ask for `yes`. If an earlier apply was interrupted, or the Lab code was just updated, run the same Lab once more to let the shared state converge.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
