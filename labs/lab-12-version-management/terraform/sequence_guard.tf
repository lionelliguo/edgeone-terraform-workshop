# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
  workshop_after_version_management_lab_ids = ["lab-13-update-version", "lab-14-purge-cache", "lab-15-prefetch-urls", "lab-16-resource-cleanup"]
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-12-version-management"

  lifecycle {
    precondition {
      condition     = contains(["lab-11-web-security-template", "lab-12-version-management"], local.workshop_previous_lab_id)
      error_message = contains(local.workshop_after_version_management_lab_ids, local.workshop_previous_lab_id) ? "A later version-management Lab has already completed. Running Lab 12 again from this state is rejected to avoid rolling back the version workflow. Continue with the next Lab in order, or run Lab 16 Resource Cleanup before starting again from Lab 01. Current previous lab_id: ${local.workshop_previous_lab_id}." : "Lab 12 sequence check failed. The shared state was not produced by Lab 11 or a previous Lab 12 run. Please start from Lab 01 and run the workshop Labs in order. Expected previous lab_id: lab-11-web-security-template or lab-12-version-management. Current Lab: lab-12-version-management. Use the shared backend state at shared/edgeone-workshop.tfstate, and run terraform init again after switching Lab directories."
    }
  }
}
