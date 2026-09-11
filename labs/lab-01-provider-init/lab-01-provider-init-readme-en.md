# Lab 01: Provider Initialization

Lab directory: `lab-01-provider-init`

## Goal

Initialize the Terraform execution environment for this workshop and confirm that the TencentCloud provider can be loaded correctly. After this Lab, participants should understand how the Terraform working directory, provider configuration, shared variable files, and shared state fit together.

This Lab does not create cloud resources. Its purpose is to establish a clean execution baseline: `terraform init` downloads the provider, `terraform validate` passes, and `terraform plan` can read the shared configuration successfully.

Objects created or managed by this Lab:

- `terraform_data.lab_sequence_guard`: Writes the current Lab ID for later sequence protection.
- Terraform local backend: Uses `shared/edgeone-workshop.tfstate` as the shared state file for all Labs.
- TencentCloud Provider configuration: Reads CAM credentials from `lab-common/credentials.auto.tfvars` for later EdgeOne API access.
- Cloud resources: none. This Lab does not create EdgeOne, DNSPod, certificate, or security resources.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-01-provider-init/terraform
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

Switch back to the Lab 01 Terraform directory:

```bash
cd ../lab-01-provider-init/terraform
```

Optional: if you want to restart the full workshop from Lab 01 and clear previous shared state, run:

```bash
./reset-shared-state.sh
```

This script only removes the local `shared/edgeone-workshop.tfstate` file and its backup/lock files. It does not delete cloud resources. It requires typing `RESET` to confirm. Use it only when restarting the workshop, when the instructor asks you to reset state, or when you are sure you no longer need the current state tracking information.

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

Lab 01 only initializes and validates the project. It does not create cloud resources.

To write `lab_success` to the shared state and view it with `terraform output`, run:

Deployment usually takes about 5 minutes. Seeing `Still creating...` or `Still modifying...` during this period is expected; keep waiting.

```bash
# Apply this Lab changes and write the result to the shared state.
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

## Expected Outputs

- Complete Terraform output list: `lab_id`, `lab_success`, `created_resource_names`, `current_execution`, `ownership_verification`, `zone_id`, `zone_name`, `zone_status`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `ownership_verification`: DNS ownership verification information.
- `zone_id`: EdgeOne Zone/Site ID.
- `zone_name`: EdgeOne Zone/Site name.
- `zone_status`: Current Zone/Site status.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-02-query-plans`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- `terraform init` completes successfully.
- `terraform validate` reports that the configuration is valid.
- `terraform plan` shows no cloud resources to create.
- After `terraform apply`, `terraform output lab_success` returns `success`.
- Lab 01 only runs with an empty shared state or a shared state already completed by Lab 01.
- If the shared state was produced by Lab 02 or a later Lab, Terraform rejects the run and tells the learner to clean up or reset state before starting again from Lab 01.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. Lab 01 supports an empty shared state and repeated `terraform plan` or `terraform apply` when `lab_id = lab-01-provider-init`. If the shared state was already written by Lab 02 or a later Lab, Lab 01 rejects the run to avoid removing later resources from Terraform management. To restart the full workshop, run Lab 16 Resource Cleanup first, or run `./reset-shared-state.sh` only after confirming that the current state tracking is no longer needed. If “will no longer be managed by Terraform, but will not be destroyed” appears before the sequence error, it is a protective Terraform state/config message before the guard rejects the run; it does not delete cloud resources. If `Lab 01 sequence check failed` also appears, sequence protection is working. Do not type yes and do not continue applying; run Lab 16 cleanup first, or reset `shared/edgeone-workshop.tfstate` only after confirmation, then start from Lab 01.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
