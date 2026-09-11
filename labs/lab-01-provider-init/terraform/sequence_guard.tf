# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
  workshop_lab01_can_run              = contains(["", "lab-01-provider-init"], local.workshop_previous_lab_id)
  workshop_version_management_lab_ids = ["lab-12-version-management", "lab-13-update-version", "lab-14-purge-cache", "lab-15-prefetch-urls", "lab-16-resource-cleanup"]
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-01-provider-init"

  lifecycle {
    precondition {
      condition     = local.workshop_lab01_can_run
      error_message = contains(local.workshop_version_management_lab_ids, local.workshop_previous_lab_id) ? "Version Management has already been enabled by Lab 12 or a later Lab. Running Lab 01 now is rejected because it can remove existing workshop resources from Terraform state. Run Lab 16 Resource Cleanup before starting again from Lab 01. Current previous lab_id: ${local.workshop_previous_lab_id}." : "Lab 01 sequence check failed. The shared state was already produced by a later Lab. Please start from Lab 01 only with an empty shared state or a previous Lab 01 run. If you want to restart the workshop, run Lab 16 Resource Cleanup or reset shared/edgeone-workshop.tfstate first. Current previous lab_id: ${local.workshop_previous_lab_id}."
    }
  }
}
