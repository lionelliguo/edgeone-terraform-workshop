# Common Lab Configuration

## Goal

Centralize the variables and credentials shared by all Labs so participants do not need to repeat the domain, origin, plan ID, and CAM key configuration in every Lab directory.

After this setup step, participants should understand the separation between `terraform.tfvars` and `credentials.auto.tfvars`: the former stores workshop parameters, while the latter stores sensitive credentials. The delivery package includes only `.example` files and excludes real configuration.

## Workshop Run Rules

- Before starting Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All executable Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each executable Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.

## Initialize

```bash
cd labs/lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Edit:

```text
terraform.tfvars
credentials.auto.tfvars
```

Each Lab `terraform/` directory reads these files explicitly with `-var-file=../../lab-common/...`, so participants only need to configure them once.

## Shared Variables

`terraform.tfvars` contains parameters shared by all Labs. `alias_zone_name` is the EdgeOne site alias shown in the console and must be different from `zone_name`; the example uses `example.com-workshop`, and real tests can use a value such as `your-domain.com-workshop`. `enable_version_deploy = true` is used by Lab 12 and Lab 13 version management Labs. Lab 12 enables version control, exports the L7 configuration, creates a configuration group version, and deploys the latest version to both Production and Staging after those environments are discovered. Lab 13 creates an updated version from the current L7 configuration, adds the Rule Engine rule `workshop-version-canary-no-cache`, and deploys it again to Production and Staging. Lab 16 is a destroy-only cleanup Lab. It can be run after any completed Lab to clean up resources already created and recorded in the shared state, and must be run with `cleanup_confirm_destroy=true` for `terraform plan -destroy` and `terraform destroy`. `version_group_id` and `version_env_id` remain optional override parameters; by default, participants do not need to copy discovered IDs manually.

## Security

Do not commit `terraform.tfvars`, `credentials.auto.tfvars`, or any real keys.

## Output Notes

All executable Labs output `current_execution` to show the current action, resource names, rule names, key actions, and next step.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
