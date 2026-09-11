# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-14-purge-cache"
}

output "purge_type" {
  description = "Cache purge type used by this Lab."
  value       = tencentcloud_teo_purge_task.www_home.type
}

output "purge_job_id" {
  description = "EdgeOne purge task job ID."
  value       = tencentcloud_teo_purge_task.www_home.job_id
}

output "purge_targets" {
  description = "Cache targets submitted for purge."
  value       = tencentcloud_teo_purge_task.www_home.targets
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_purge_task.www_home.job_id != "" ? "success" : "failed"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab. Earlier resources are dependencies only."
  value = {
    purge_task_target = one(tencentcloud_teo_purge_task.www_home.targets)
    purge_task_type   = tencentcloud_teo_purge_task.www_home.type
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-14-purge-cache"
    action            = "Submit an EdgeOne cache purge task for the www home URL."
    execution_mode    = "apply"
    created_resources = ["tencentcloud_teo_purge_task.www_home"]
    resource_names = {
      purge_job_id = tencentcloud_teo_purge_task.www_home.job_id
      purge_type   = tencentcloud_teo_purge_task.www_home.type
      targets      = tencentcloud_teo_purge_task.www_home.targets
    }
    rule_names      = {}
    expected_result = "The target URL is submitted for cache purge."
    next_lab        = "lab-15-prefetch-urls"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "ensure"
      resource  = "tencentcloud_teo_deploy_config_group_version.workshop_l7_update"
      name      = try(tencentcloud_teo_config_group_version.workshop_l7_update[0].version_id, "updated L7 version")
      details = {
        updated_version_id  = try(tencentcloud_teo_config_group_version.workshop_l7_update[0].version_id, null)
        updated_rule_engine = local.update_version_rule_engine_rule_name
      }
    },
    {
      step      = 2
      operation = "create"
      resource  = "tencentcloud_teo_purge_task.www_home"
      name      = tencentcloud_teo_purge_task.www_home.job_id
      details = {
        purge_type    = tencentcloud_teo_purge_task.www_home.type
        purge_targets = join(",", tencentcloud_teo_purge_task.www_home.targets)
        job_id        = tencentcloud_teo_purge_task.www_home.job_id
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-15-prefetch-urls"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-14-purge-cache"
    lab_success = tencentcloud_teo_purge_task.www_home.job_id != "" ? "success" : "failed"
    next_lab    = "lab-15-prefetch-urls"
  }
}
