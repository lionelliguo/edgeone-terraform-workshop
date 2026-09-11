# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
locals {
  workshop_state_path = "${path.module}/../../../shared/edgeone-workshop.tfstate"
  workshop_previous_lab_id = fileexists(local.workshop_state_path) ? try(
    jsondecode(file(local.workshop_state_path)).outputs.lab_id.value,
    ""
  ) : ""
}

resource "terraform_data" "lab_sequence_guard" {
  input = "lab-15-prefetch-urls"

  lifecycle {
    precondition {
      condition     = contains(["lab-14-purge-cache", "lab-15-prefetch-urls"], local.workshop_previous_lab_id)
      error_message = "Lab 15 sequence check failed. The shared state was not produced by Lab 14 or a previous Lab 15 run. Please start from Lab 01 and run the workshop Labs in order. Expected previous lab_id: lab-14-purge-cache or lab-15-prefetch-urls. Current Lab: lab-15-prefetch-urls. Use the shared backend state at shared/edgeone-workshop.tfstate, and run terraform init again after switching Lab directories."
    }
  }
}
