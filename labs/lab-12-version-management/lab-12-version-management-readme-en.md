# Lab 12: Version Management

Lab directory: `lab-12-version-management`

## Goal

Enable version control mode for the EdgeOne L7 acceleration configuration group, export the current L7 acceleration configuration, create a new configuration group version, and deploy that version to both Production and Staging.

This Lab does not directly add a new immediate-effect Rule Engine rule. Instead, it packages the current L7 acceleration configuration into a version-managed configuration group version. The version content includes the L7 rule created by previous Labs:

- `workshop-www-https-cache`: Includes HTTPS redirect, 30-day static asset caching, and dynamic no-cache behavior.

Security rules continue to be managed by Zone Default Policy and the Web Security Template, including `monitor-curl-on-login`, `bot-monitor-api-curl`, `monitor-api-curl`, `login-single-ip-rate-limit`, and `health-check-skip-security-modules`. The focus of this Lab is to version and deploy the L7 configuration to Production and Staging.

This Lab sits after the Web Security Template Lab and before the cache operations Labs. It helps participants understand the versioned EdgeOne configuration workflow: enable version control, export configuration, create a version, and deploy the version. By default, `enable_version_deploy = true`, and Terraform automatically discovers the L7 configuration group ID, Production environment ID, and Staging environment ID.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-12-version-management/terraform
```

## Prepare Variables

All Labs share the same configuration files. Configure them once before the first Lab:

```bash
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Edit `labs/lab-common/terraform.tfvars` and `labs/lab-common/credentials.auto.tfvars` with your test domain, plan_id, origin, and CAM credentials. This Lab explicitly reads the shared configuration with `-var-file=../../lab-common/...`.

Optional variables:

- `enable_version_management`: Whether to create a configuration group version. Default: `true`.
- `enable_version_deploy`: Whether to deploy the new version. Default: `true`. By default, the version is deployed to both Production and Staging.
- `version_group_id`: Optional L7 configuration group ID. By default, Terraform uses `discovered_version_group_id`; set this only when you want to pin a specific group.
- `version_env_id`: Optional environment ID. By default, Terraform uses the discovered Production and Staging environments; set this only when you want to override deployment to one specific environment.

## Commands

Switch back to this Lab Terraform directory:

```bash
cd ../lab-12-version-management/terraform
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

Deployment can take more than 10 minutes. Before version management is enabled for the first time, Terraform first waits about 300 seconds for previous configuration changes to settle; after it is enabled, Terraform waits about 300 seconds for the EdgeOne Production/Staging environments to become ready. Seeing `Still creating...` or `Still modifying...` during this period is expected; keep waiting.

```bash
# Apply this Lab changes and write the result to the shared state.
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

After a successful apply, Terraform outputs the discovered `discovered_version_group_id`, `discovered_production_env_id`, and `discovered_staging_env_id`, plus the newly created `config_group_version_id`. Terraform waits before enabling version management and again before reading environments and deploying the version to avoid transient EdgeOne readiness errors such as `FailedOperation` or `OperationDenied.EnvNotReady`. By default, the new version is deployed to Staging first and then serially to Production.

If you want to pin a specific configuration group, or override deployment to one specific environment, you can still add them to `labs/lab-common/terraform.tfvars`:

```hcl
version_group_id = "cg-xxxxxxxxxxxx"
version_env_id   = "env-xxxxxxxxxxxx"
```

Then run `terraform plan` and `terraform apply` to create and deploy the configuration group version.

## Expected Outputs

- Complete Terraform output list: `lab_id`, `version_management_enabled`, `version_deploy_enabled`, `version_config_type`, `version_control_work_mode`, `version_env_id`, `discovered_version_env_id`, `discovered_production_env_id`, `discovered_staging_env_id`, `version_deploy_env_ids`, `version_group_id`, `discovered_version_group_id`, `version_resource_status`, `config_group_version_id`, `config_group_version_number`, `deploy_record_id`, `deploy_status`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
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
- `config_group_version_id`: Initial configuration group version ID.
- `config_group_version_number`: Initial configuration group version number.
- `deploy_record_id`: Initial version deployment record ID.
- `deploy_status`: Initial version deployment status.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-13-update-version`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform configures the Zone `l7_acceleration` work mode as `version_control`.
- Terraform exports `L7AccelerationConfig` with `tencentcloud_teo_export_zone_config`.
- Terraform queries EdgeOne environment information with `tencentcloud_teo_environments` and automatically uses the discovered L7 configuration group ID and environment ID.
- `version_resource_status` is `created`.
- If `version_resource_status = created`, `config_group_version_id` is populated.
- Version deployment is enabled by default. `deploy_status` should show deployment results for both Production and Staging.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
