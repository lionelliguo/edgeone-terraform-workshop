# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-02-query-plans"
}

output "available_edgeone_plans" {
  description = "EdgeOne plans available to the current account."
  value       = data.tencentcloud_teo_zone_available_plans.available.plan_info_list
}

output "lab_success" {
  description = "Lab completion status."
  value       = length(data.tencentcloud_teo_zone_available_plans.available.plan_info_list) > 0 ? "success" : "failed"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab. Empty because Lab 02 only queries available plans."
  value       = []
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id             = "lab-02-query-plans"
    action             = "Query EdgeOne plans available to the current Tencent Cloud account."
    execution_mode     = "apply"
    created_resources  = []
    managed_resources  = []
    queried_data       = ["tencentcloud_teo_zone_available_plans.available"]
    available_plan_cnt = length(data.tencentcloud_teo_zone_available_plans.available.plan_info_list)
    rule_names         = {}
    expected_result    = "Available EdgeOne plans are listed for selecting plan_id."
    next_lab           = "lab-03-create-site"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "query"
      resource  = "data.tencentcloud_teo_zone_available_plans.available"
      name      = "available EdgeOne plans"
      details = {
        available_plan_count = length(data.tencentcloud_teo_zone_available_plans.available.plan_info_list)
        selected_plan_id     = var.plan_id
        cloud_resource       = "none"
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-03-create-site"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-02-query-plans"
    lab_success = length(data.tencentcloud_teo_zone_available_plans.available.plan_info_list) > 0 ? "success" : "failed"
    next_lab    = "lab-03-create-site"
  }
}
