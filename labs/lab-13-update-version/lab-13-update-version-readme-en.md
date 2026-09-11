# Lab 13: Update Version

Lab directory: `lab-13-update-version`

## Goal

Use the EdgeOne Version Management mode enabled in Lab 12, export the current L7 acceleration configuration, generate an updated configuration group version, and deploy the new version to both Production and Staging.

Rules and actions created or carried by this Lab through Version Management:

- `workshop-www-https-cache`: Carries forward the Rule Engine rule from the previous version for HTTPS redirect, 30-day static asset caching, and dynamic no-cache behavior.
- `workshop-version-canary-no-cache`: Adds a Rule Engine rule to the updated version. It matches `/version-canary/*` and sets no-cache, providing a canary validation path for the versioned deployment workflow.

This Lab does not directly call the immediate-effect L7 Rule API to modify online rules. It exports the current `L7AccelerationConfig`, generates a new configuration group version, and deploys it to Staging and Production. Security rules remain managed by the earlier Zone Default Policy and Web Security Template.

This Lab demonstrates the recommended change workflow in version control mode: do not call the immediate-effect L7 Rule API directly. Instead, export the configuration, create a new version, and deploy that version. To make the version difference easier to see, this Lab updates the original rule description to `Managed by Terraform workshop - updated version` and adds a Rule Engine rule named `workshop-version-canary-no-cache`. The new rule only matches `/version-canary/*` and disables cache for that path, without changing the existing HTTPS redirect, static asset cache policy, or origin settings.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-13-update-version/terraform
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
cd ../lab-13-update-version/terraform
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

Deployment can take more than 10 minutes. Terraform first waits about 300 seconds for the version-management environment and previous deployment state to settle; it then waits about 300 seconds before reading environments and deploying the updated version. Seeing `Still creating...` or `Still modifying...` during this period is expected; keep waiting.

```bash
# Apply this Lab changes and write the result to the shared state.
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

## Expected Outputs

- Complete Terraform output list: `lab_id`, `version_management_enabled`, `version_deploy_enabled`, `version_config_type`, `version_control_work_mode`, `version_env_id`, `discovered_version_env_id`, `discovered_production_env_id`, `discovered_staging_env_id`, `version_deploy_env_ids`, `version_group_id`, `discovered_version_group_id`, `version_resource_status`, `updated_version_resource_status`, `config_group_version_id`, `config_group_version_number`, `deploy_record_id`, `deploy_status`, `updated_config_group_version_id`, `updated_config_group_version_number`, `updated_rule_engine_rule_name`, `updated_deploy_record_id`, `updated_deploy_status`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `version_management_enabled`: Whether Version Management is enabled.
- `version_deploy_enabled`: Whether version deployment is enabled.
- `version_config_type`: Version-management configuration type.
- `version_control_work_mode`: Version-control work mode.
- `version_env_id`: Backward-compatible effective environment ID.
- `discovered_version_env_id`: Discovered environment ID.
- `discovered_production_env_id`: Discovered Production environment ID.
- `discovered_staging_env_id`: Discovered Staging environment ID.
- `version_deploy_env_ids`: Target environment IDs for version deployment.
- `version_group_id`: Configuration group ID used to create versions.
- `discovered_version_group_id`: Discovered configuration group ID.
- `version_resource_status`: Initial configuration group version resource status.
- `updated_version_resource_status`: Updated configuration group version resource status.
- `config_group_version_id`: Initial configuration group version ID.
- `config_group_version_number`: Initial configuration group version number.
- `deploy_record_id`: Initial version deployment record ID.
- `deploy_status`: Initial version deployment status.
- `updated_config_group_version_id`: Updated configuration group version ID.
- `updated_config_group_version_number`: Updated configuration group version number.
- `updated_rule_engine_rule_name`: Rule Engine rule name added by the updated version.
- `updated_deploy_record_id`: Updated version deployment record ID.
- `updated_deploy_status`: Updated version deployment status.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-14-purge-cache`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform does not try to create or modify `tencentcloud_teo_l7_acc_rule_v2`, avoiding version-control lock errors.
- Terraform creates `tencentcloud_teo_config_group_version.workshop_l7_update`.
- The updated version content includes the new Rule Engine rule `workshop-version-canary-no-cache`.
- Terraform creates `tencentcloud_teo_deploy_config_group_version.workshop_l7_update["production"]` and `["staging"]`.
- `updated_config_group_version_id` is populated.
- `updated_deploy_status` returns deployment results for both Production and Staging.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
