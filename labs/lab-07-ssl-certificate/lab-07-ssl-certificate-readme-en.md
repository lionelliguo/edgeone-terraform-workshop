# Lab 07: SSL Certificate

Lab directory: `lab-07-ssl-certificate`

## Goal

Enable HTTPS certificate configuration for the `www` acceleration domain, using either an EdgeOne free certificate or an existing SSL certificate.

Resources created or managed by this Lab:

- `tencentcloud_teo_zone.zone`: Continues to manage the EdgeOne Zone.
- `tencentcloud_teo_acceleration_domain.www`: Continues to manage the `www` acceleration domain as the certificate binding target.
- `tencentcloud_teo_certificate_config.www`: Configures the certificate for the `www` acceleration domain. When `certificate_mode = "eofreecert"`, it requests or uses an EdgeOne free certificate; when `certificate_mode = "sslcert"`, it binds the existing certificate specified by `ssl_cert_id`.
- `tencentcloud_dnspod_record.www_cname`: Optional resource. It continues to manage the business CNAME record in automated DNSPod mode.
- `terraform_data.lab_sequence_guard`: Writes the current Lab ID to shared state so Lab 08 can only run after Lab 07.

This Lab does not attempt to cover the full certificate lifecycle. Instead, it focuses on how Terraform binds the certificate mode, optional certificate ID, and acceleration domain together. Participants should verify the certificate configuration ID, certificate mode, and protected host from the outputs.

## Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Working Directory

```bash
cd labs/lab-07-ssl-certificate/terraform
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
cd ../lab-07-ssl-certificate/terraform
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

- Complete Terraform output list: `lab_id`, `https_host`, `certificate_mode`, `certificate_config_id`, `lab_success`, `created_resource_names`, `current_execution`, `execution_steps`, `next_lab`, `workshop_result`.
- `lab_id`: Lab identifier most recently completed and written to the shared state. Later Labs use this for sequence protection.
- `https_host`: Host configured for SSL certificate.
- `certificate_mode`: Certificate configuration mode.
- `certificate_config_id`: EdgeOne certificate configuration ID.
- `lab_success`: Lab completion status. `success` means the Lab objective was completed.
- `created_resource_names`: Summary of resource names created or managed by this Lab. Kept for compatibility with earlier workshop versions.
- `current_execution`: Human-readable execution summary for this Lab, including action, execution_mode, resource names, rule names, key actions, and next step.
- `execution_steps`: Ordered list of resources created, modified, or destroyed by this Lab, including resource type, resource name, key IDs, rule names, actions, and targets.
- `next_lab`: Recommended next Lab after this Lab succeeds. Next Lab: `lab-08-rule-engine`.
- `workshop_result`: Final result summary with `lab_id`, `lab_success`, and `next_lab`.

## Success Criteria

- Terraform creates `tencentcloud_teo_certificate_config.www` when `enable_certificate = true`.
- `certificate_config_id` is populated when certificate configuration is enabled.
- The certificate host matches the acceleration domain.

## State Note

This Lab uses the shared local backend: `shared/edgeone-workshop.tfstate`. After switching from the previous Lab, run `terraform init` again.

Sequence protection allows this Lab to run `terraform plan` or `terraform apply` again after it has completed successfully. If the shared state `lab_id` is neither the previous Lab nor the current Lab, Terraform asks the learner to start from Lab 01 and run the Labs in order.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
