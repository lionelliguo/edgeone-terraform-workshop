# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = local.workshop_lab01_can_run ? "lab-01-provider-init" : try(jsondecode(file(local.workshop_state_path)).outputs.lab_id.value, local.workshop_previous_lab_id)
}

output "lab_success" {
  description = "Lab completion status."
  value       = local.workshop_lab01_can_run ? "success" : try(jsondecode(file(local.workshop_state_path)).outputs.lab_success.value, "blocked")
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab. Empty because Lab 01 only initializes the provider."
  value       = jsondecode(local.workshop_lab01_can_run ? jsonencode([]) : try(jsonencode(jsondecode(file(local.workshop_state_path)).outputs.created_resource_names.value), jsonencode([])))
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = jsondecode(local.workshop_lab01_can_run ? jsonencode({
    lab_id            = "lab-01-provider-init"
    action            = "Initialize Terraform backend and TencentCloud provider."
    execution_mode    = "apply"
    created_resources = []
    managed_resources = []
    rule_names        = {}
    expected_result   = "Provider initialized and configuration validated; no cloud resources are created."
    next_lab          = "lab-02-query-plans"
    }) : try(jsonencode(jsondecode(file(local.workshop_state_path)).outputs.current_execution.value), jsonencode({
      lab_id            = local.workshop_previous_lab_id
      action            = "Blocked by sequence guard."
      execution_mode    = "plan"
      created_resources = []
      managed_resources = []
      rule_names        = {}
      expected_result   = "Lab 01 is blocked because a later Lab already wrote shared state."
      next_lab          = "lab-16-resource-cleanup"
  })))
}

output "ownership_verification" {
  description = "Preserves the existing output when Lab 01 is accidentally run after a later Lab."
  value       = jsondecode(local.workshop_lab01_can_run ? "null" : try(jsonencode(jsondecode(file(local.workshop_state_path)).outputs.ownership_verification.value), "null"))
}

output "zone_id" {
  description = "Preserves the existing output when Lab 01 is accidentally run after a later Lab."
  value       = local.workshop_lab01_can_run ? null : try(jsondecode(file(local.workshop_state_path)).outputs.zone_id.value, null)
}

output "zone_name" {
  description = "Preserves the existing output when Lab 01 is accidentally run after a later Lab."
  value       = local.workshop_lab01_can_run ? null : try(jsondecode(file(local.workshop_state_path)).outputs.zone_name.value, null)
}

output "zone_status" {
  description = "Preserves the existing output when Lab 01 is accidentally run after a later Lab."
  value       = local.workshop_lab01_can_run ? null : try(jsondecode(file(local.workshop_state_path)).outputs.zone_status.value, null)
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "initialize"
      resource  = "terraform backend and TencentCloud provider"
      name      = "local shared backend"
      details = {
        backend_state   = local.workshop_state_path
        cloud_resource  = "none"
        expected_result = "Provider initialized and configuration validated."
        sequence_guard  = local.workshop_lab01_can_run ? "ready" : "blocked_by_later_lab"
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = local.workshop_lab01_can_run ? "lab-02-query-plans" : "lab-16-resource-cleanup"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = local.workshop_lab01_can_run ? "lab-01-provider-init" : try(jsondecode(file(local.workshop_state_path)).outputs.lab_id.value, local.workshop_previous_lab_id)
    lab_success = local.workshop_lab01_can_run ? "success" : try(jsondecode(file(local.workshop_state_path)).outputs.lab_success.value, "blocked")
    next_lab    = local.workshop_lab01_can_run ? "lab-02-query-plans" : "lab-16-resource-cleanup"
  }
}
