# Lab 16: Resource Cleanup

Lab directory: `lab-16-resource-cleanup`

## Goal

Use `terraform destroy` to clean up the EdgeOne, DNSPod, Security Template, cache task, and related workshop resources managed by Terraform, then verify that shared state is empty.

This Lab can be run after any completed Lab to destroy the workshop resources that have already been created or managed in the current shared state. Cleanup targets include:

- `tencentcloud_teo_prefetch_task_operation.www_home`: Removes Terraform management for the URL prefetch task.
- `tencentcloud_teo_purge_task.www_home`: Removes Terraform management for the URL purge task.
- `tencentcloud_teo_deploy_config_group_version.*`: Cleans up version deployment records for the initial and updated versions across Staging, Production, or a custom environment.
- `tencentcloud_teo_config_group_version.*`: Cleans up L7 configuration group versions created by Version Management.
- `tencentcloud_teo_bind_security_template.www`: Unbinds the Web Security Template from the `www` acceleration domain.
- `tencentcloud_teo_web_security_template.workshop`: Deletes the Web Security Template `workshop_www_security`, including its Custom Rule, Bot Custom Rule, Rate Limiting, and Exception Rule configuration.
- `tencentcloud_teo_security_policy_config.zone_default`: Cleans up workshop-managed Monitor rules and Bot Intelligence configuration in the Zone default security policy.
- `tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache`: Deletes the Rule Engine rule `workshop-www-https-cache`.
- `tencentcloud_teo_certificate_config.www`: Deletes the certificate configuration for the `www` acceleration domain.
- `tencentcloud_dnspod_record.www_cname`: Optional resource. In automated DNSPod mode, deletes the business CNAME record.
- `tencentcloud_teo_acceleration_domain.www`: Deletes the `www` business acceleration domain.
- `tencentcloud_teo_ownership_verify.zone` and `tencentcloud_dnspod_record.ownership`: Clean up the ownership verification resource and optional DNSPod verification record.
- `tencentcloud_teo_zone.zone`: Deletes the EdgeOne Zone.
- `terraform_data.lab_sequence_guard`: Deletes the local sequence guard record.

This Lab closes the full workflow: create, verify, change, output, and clean up. Participants should understand which resources Terraform destroys automatically, which manual DNS records must be removed in an external console, and how to validate cleanup with `terraform state list`.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged. Lab 16 is destroy-only and can be run after any completed Lab to clean up workshop resources already recorded in the shared state; it can also be repeated with `plan -destroy` or `destroy`. After cleanup completes, running it again should keep the empty state and delete no additional resources.

## Working Directory

```bash
cd labs/lab-16-resource-cleanup/terraform
```

## Prepare Variables

All Labs share the same configuration files. Configure them once before the first Lab:

```bash
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Edit `labs/lab-common/terraform.tfvars` and `labs/lab-common/credentials.auto.tfvars` with your test domain, plan_id, origin, and CAM credentials.

## Commands

Switch back to this Lab Terraform directory:

```bash
cd ../lab-16-resource-cleanup/terraform
```

```bash
# Initialize this Lab backend and the TencentCloud Provider.
terraform init
# Format the Terraform configuration files in this directory.
terraform fmt
# Validate Terraform syntax and provider schema usage.
terraform validate
```

Run cleanup:

Note: Lab 16 is a destroy-only cleanup Lab. Whether you have completed Lab 03, Lab 10, Lab 13, or Lab 15, you can enter this Lab to clean up resources already created and recorded in the shared state. Do not run normal `terraform apply`; normal apply does not delete resources and is now blocked by configuration protection.

Deployment usually takes about 5 minutes. Seeing `Still creating...` or `Still modifying...` during this period is expected; keep waiting.

```bash
# Preview the workshop resources that will be destroyed without deleting anything yet.
terraform plan -destroy -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars -var="cleanup_confirm_destroy=true"
# Delete the workshop-managed resources recorded in the current Terraform state.
terraform destroy -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars -var="cleanup_confirm_destroy=true"
```

## Expected Outputs

- Complete Terraform output list: `lab_id`, `lab_success`, `cleanup_resource_names`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `cleanup_resource_names`: Cleanup target resource names and rule names listed before Lab 16 destroy.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-01-provider-init`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- `terraform plan -destroy` shows the expected EdgeOne and optional DNSPod resources to remove.
- `terraform destroy` completes successfully.
- `terraform state list` returns no workshop-managed resources after cleanup.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to start from the shared state of any completed Lab, and also allows `plan -destroy` or `destroy` to be rerun after cleanup succeeds. Lab 16 remains a destroy-only Lab and does not support normal `apply`.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
