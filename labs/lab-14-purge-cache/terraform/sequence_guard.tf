# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-14-purge-cache"

  lifecycle {
    precondition {
      condition     = contains(["lab-13-update-version", "lab-14-purge-cache"], local.workshop_previous_lab_id)
      error_message = "Lab 14 sequence check failed. The shared state was not produced by Lab 13 or a previous Lab 14 run. Please start from Lab 01 and run the workshop Labs in order. Expected previous lab_id: lab-13-update-version or lab-14-purge-cache. Current Lab: lab-14-purge-cache. Use the shared backend state at shared/edgeone-workshop.tfstate, and run terraform init again after switching Lab directories."
    }
  }
}
