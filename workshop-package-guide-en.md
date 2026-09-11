# Tencent Cloud EdgeOne Terraform Workshop Package Guide

Version date: 2026-08-01  
Mapped agenda: 3-day training, 3 hours per day, EdgeOne hands-on focused

## Package Goal

This package guides participants through creating and validating a Tencent Cloud EdgeOne onboarding workflow with Terraform. Terraform is kept intentionally lightweight, while the hands-on work focuses on EdgeOne site creation, domain ownership verification, acceleration domain setup, CNAME, HTTPS, L7 rules, security policy, and troubleshooting.

By the end of the workshop, participants should be able to:

- Manage Tencent Cloud CAM credentials through a configuration file.
- Initialize the TencentCloud Terraform Provider.
- Query available EdgeOne plans and confirm `plan_id`.
- Create an EdgeOne site.
- Complete domain ownership verification.
- Create an acceleration domain and configure the origin.
- Configure business CNAME and HTTPS.
- Configure basic L7 acceleration rules.
- Understand security policy management through a Monitor-mode example.
- Complete the full Terraform workflow with plan, apply, state, output, and destroy.
- Configure extended Labs such as Bot Intelligence, Web Security Template, cache purge, and cache prefetch.

## Directory Structure

```text
edgeone-terraform-workshop/
  workshop-package-guide-cn.md
  workshop-package-guide-en.md
  agenda/
    agenda-3day-3hour-cn.md
    agenda-3day-3hour-en.md
    agenda-3day-3hour-cn.docx
    agenda-3day-3hour-en.docx
  labs/
    lab-guide-cn.md
    lab-guide-en.md
    lab-common/
      lab-common-readme-cn.md
      lab-common-readme-en.md
      terraform.tfvars.example
      credentials.auto.tfvars.example
    lab-01-provider-init/
      lab-01-provider-init-readme-cn.md
      lab-01-provider-init-readme-en.md
      terraform/
    lab-02-query-plans/
      lab-02-query-plans-readme-cn.md
      lab-02-query-plans-readme-en.md
      terraform/
    lab-03-create-site/
      lab-03-create-site-readme-cn.md
      lab-03-create-site-readme-en.md
      terraform/
    lab-04-ownership-verify/
      lab-04-ownership-verify-readme-cn.md
      lab-04-ownership-verify-readme-en.md
      terraform/
    lab-05-domain-management/
      lab-05-domain-management-readme-cn.md
      lab-05-domain-management-readme-en.md
      terraform/
    lab-06-cname-setup/
      lab-06-cname-setup-readme-cn.md
      lab-06-cname-setup-readme-en.md
      terraform/
    lab-07-ssl-certificate/
      lab-07-ssl-certificate-readme-cn.md
      lab-07-ssl-certificate-readme-en.md
      terraform/
    lab-08-rule-engine/
      lab-08-rule-engine-readme-cn.md
      lab-08-rule-engine-readme-en.md
      terraform/
    lab-09-security-policy/
      lab-09-security-policy-readme-cn.md
      lab-09-security-policy-readme-en.md
      terraform/
    lab-10-bot-intelligence/
      lab-10-bot-intelligence-readme-cn.md
      lab-10-bot-intelligence-readme-en.md
      terraform/
    lab-11-web-security-template/
      lab-11-web-security-template-readme-cn.md
      lab-11-web-security-template-readme-en.md
      terraform/
    lab-12-version-management/
      lab-12-version-management-readme-cn.md
      lab-12-version-management-readme-en.md
      terraform/
    lab-13-update-version/
      lab-13-update-version-readme-cn.md
      lab-13-update-version-readme-en.md
      terraform/
    lab-14-purge-cache/
      lab-14-purge-cache-readme-cn.md
      lab-14-purge-cache-readme-en.md
      terraform/
    lab-15-prefetch-urls/
      lab-15-prefetch-urls-readme-cn.md
      lab-15-prefetch-urls-readme-en.md
      terraform/
    lab-16-resource-cleanup/
      lab-16-resource-cleanup-readme-cn.md
      lab-16-resource-cleanup-readme-en.md
      terraform/
  shared/
    shared-readme-cn.md
    shared-readme-en.md
```

Notes:

- `labs/lab-xx-*/terraform/` contains staged classroom code. Each Lab only includes Terraform configuration required for that stage.
- `labs/lab-common/` stores `terraform.tfvars` and `credentials.auto.tfvars` shared by all Labs.
- Each Lab explicitly reads the shared configuration with `-var-file=../../lab-common/...`.
- All Lab directories share `shared/edgeone-workshop.tfstate` through a local backend, so they can be run sequentially.
- `shared/` is the shared Terraform state directory. `edgeone-workshop.tfstate` is generated at runtime and excluded from the delivery package.
- For formal training, participants should use the staged Labs under `labs/lab-xx-*/terraform/`.
- After Lab 12 enables Version Management, Lab 01 through Lab 11 refuse to run. This avoids changing earlier immediate-effect configuration while the site is in `version_control` mode. To restart, run Lab 16 to clean up resources and shared state first.
- Lab 16 is a destroy-only cleanup Lab. It can be run after any completed Lab to clean up resources already created and recorded in the shared state; it must be run with `terraform plan -destroy` and `terraform destroy` plus `cleanup_confirm_destroy=true`. Normal `terraform apply` does not delete resources.
- Some Lab `terraform/removed.tf` files keep compatibility with state records left by later Labs. Terraform only forgets those records from state and does not destroy cloud resources. Seeing “will no longer be managed by Terraform, but will not be destroyed” is an expected state compatibility notice; actual execution is still controlled by the sequence guard.

## Workshop Run Rules

- Before starting Lab 01, go to `labs/lab-01-provider-init/terraform` and run `./reset-shared-state.sh` to reset the shared state to the initial state. The script only cleans local state; it does not delete cloud resources.
- All Labs must be run in order from `lab-01` to `lab-16`. Each Lab's `sequence_guard.tf` checks the previous `lab_id` in the shared state during Terraform execution. If the order is incorrect, it asks the participant to start from Lab 01 and run the Labs in order, and blocks the current resource change.
- Each Lab is designed to be idempotent. The same Lab can be run multiple times with `plan` or `apply`; when the resources already match the configuration, Terraform should show no changes or keep the final result unchanged.
- Each README uses native Terraform commands: `terraform plan/apply/destroy`. Sequence protection is enforced by each Lab's `sequence_guard.tf`.

## Credential Configuration

This workshop uses a local credential configuration file. Participants copy the example file:

```bash
cd labs/lab-common
cp credentials.auto.tfvars.example credentials.auto.tfvars
```

Then fill in:

```hcl
tencentcloud_secret_id  = "REPLACE_WITH_TENCENTCLOUD_SECRET_ID"
tencentcloud_secret_key = "REPLACE_WITH_TENCENTCLOUD_SECRET_KEY"
```

Security requirements:

- Do not commit `credentials.auto.tfvars`.
- Do not expose real keys in screenshots, recordings, or chat tools.
- Disable or delete temporary CAM keys after training.
- For production, prefer CI/CD secrets, temporary credentials, role-based access, or OIDC.

## Terraform Execution Path

Each Lab has its own working directory. For example:

```bash
cd labs/lab-01-provider-init/terraform
./reset-shared-state.sh
cd ../../lab-common
cp terraform.tfvars.example terraform.tfvars
cp credentials.auto.tfvars.example credentials.auto.tfvars
cd ../..

cd labs/lab-03-create-site/terraform
terraform init
terraform fmt
terraform validate
terraform plan -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
terraform apply -var-file=../../lab-common/terraform.tfvars -var-file=../../lab-common/credentials.auto.tfvars
```

When moving to the next Lab, switch to the next directory:

```bash
cd ../../lab-04-ownership-verify/terraform
terraform init
```

## Real Execution Requirements

```text
1. Valid Tencent Cloud CAM credentials.
2. CAM permissions for EdgeOne, SSL Certificate, and DNSPod where needed.
3. An available EdgeOne plan_id.
4. A controlled test domain.
5. Ability to create DNS verification records.
6. A publicly reachable origin.
7. Ability to point the business CNAME to the EdgeOne CNAME.
```

## Expected Results

Example Terraform outputs:

```text
zone_id = "zone-xxxxxx"
acceleration_domain = "www.example.com"
edgeone_cname = "www.example.com.eo.dnse0.com"
```

DNS validation:

```bash
dig +short CNAME www.example.com
```

Expected result:

```text
www.example.com.eo.dnse0.com.
```

Access validation:

```bash
curl -I http://www.example.com
curl -I https://www.example.com
```

HTTP should show EdgeOne response headers, such as:

```text
Server: TencentEdgeOne
```

The HTTPS status code depends on certificate readiness, origin protocol, and origin availability.

## Delivery Note

Use the following zip for formal delivery:

```text
outputs/edgeone-terraform-workshop.zip
```

The delivery zip should not contain real credentials, real `terraform.tfvars`, state backups, or the `.terraform/` directory. `shared/edgeone-workshop.tfstate` is kept as an empty initial state for the sequential Workshop flow.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
