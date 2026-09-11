# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-16-resource-cleanup"

  lifecycle {
    precondition {
      condition = contains([
        "",
        "lab-01-provider-init",
        "lab-02-query-plans",
        "lab-03-create-site",
        "lab-04-ownership-verify",
        "lab-05-domain-management",
        "lab-06-cname-setup",
        "lab-07-ssl-certificate",
        "lab-08-rule-engine",
        "lab-09-security-policy",
        "lab-10-bot-intelligence",
        "lab-11-web-security-template",
        "lab-12-version-management",
        "lab-13-update-version",
        "lab-14-purge-cache",
        "lab-15-prefetch-urls",
        "lab-16-resource-cleanup"
      ], local.workshop_previous_lab_id)
      error_message = "Lab 16 cleanup can run from any previous workshop Lab, but the shared state does not look like this workshop state. Please verify that you are using shared/edgeone-workshop.tfstate, then run terraform init again after switching Lab directories. Current previous lab_id: ${local.workshop_previous_lab_id}."
    }

    precondition {
      condition     = var.cleanup_confirm_destroy
      error_message = "Lab 16 is a destroy-only cleanup Lab. Do not run normal terraform apply. Use terraform plan -destroy -var='cleanup_confirm_destroy=true' and terraform destroy -var='cleanup_confirm_destroy=true' with the shared var files to delete workshop resources."
    }
  }
}
