# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
  workshop_version_management_lab_ids = ["lab-12-version-management", "lab-13-update-version", "lab-14-purge-cache", "lab-15-prefetch-urls", "lab-16-resource-cleanup"]
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-11-web-security-template"

  lifecycle {
    precondition {
      condition     = contains(["lab-10-bot-intelligence", "lab-11-web-security-template"], local.workshop_previous_lab_id)
      error_message = contains(local.workshop_version_management_lab_ids, local.workshop_previous_lab_id) ? "Version Management has already been enabled by Lab 12 or a later Lab. Running Lab 11 now is rejected to avoid changing earlier immediate-effect configuration after version control is enabled. Continue with the next version-management Lab, or run Lab 16 Resource Cleanup before starting again from Lab 01. Current previous lab_id: ${local.workshop_previous_lab_id}." : "Lab 11 sequence check failed. The shared state was not produced by lab-10-bot-intelligence or a previous lab-11-web-security-template run. Please start from Lab 01 and run the workshop Labs in order. Expected previous lab_id: lab-10-bot-intelligence or lab-11-web-security-template. Current Lab: lab-11-web-security-template. Use the shared backend state at shared/edgeone-workshop.tfstate, and run terraform init again after switching Lab directories."
    }
  }
}
