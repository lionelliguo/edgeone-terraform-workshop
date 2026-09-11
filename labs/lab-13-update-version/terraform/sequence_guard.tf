# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-13-update-version"

  lifecycle {
    precondition {
      condition     = contains(["lab-12-version-management", "lab-13-update-version"], local.workshop_previous_lab_id)
      error_message = "Lab 13 sequence check failed. The shared state was not produced by Lab 12 or a previous Lab 13 run. Please start from Lab 01 and run the workshop Labs in order. Expected previous lab_id: lab-12-version-management or lab-13-update-version. Current Lab: lab-13-update-version. Use the shared backend state at shared/edgeone-workshop.tfstate, and run terraform init again after switching Lab directories."
    }
  }
}
