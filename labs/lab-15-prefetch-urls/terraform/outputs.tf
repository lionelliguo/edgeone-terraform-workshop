# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-15-prefetch-urls"
}

output "prefetch_job_id" {
  description = "EdgeOne prefetch task job ID."
  value       = tencentcloud_teo_prefetch_task_operation.www_home.job_id
}

output "prefetch_targets" {
  description = "Cache targets submitted for prefetch."
  value       = tencentcloud_teo_prefetch_task_operation.www_home.targets
}

output "prefetch_mode" {
  description = "Prefetch mode used by this Lab."
  value       = tencentcloud_teo_prefetch_task_operation.www_home.mode
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_prefetch_task_operation.www_home.job_id != "" ? "success" : "failed"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab. Earlier resources are dependencies only."
  value = {
    prefetch_task_target = one(tencentcloud_teo_prefetch_task_operation.www_home.targets)
    prefetch_task_mode   = tencentcloud_teo_prefetch_task_operation.www_home.mode
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-15-prefetch-urls"
    action            = "Submit an EdgeOne URL prefetch task for the www home URL."
    execution_mode    = "apply"
    created_resources = ["tencentcloud_teo_prefetch_task_operation.www_home"]
    resource_names = {
      prefetch_job_id = tencentcloud_teo_prefetch_task_operation.www_home.job_id
      prefetch_mode   = tencentcloud_teo_prefetch_task_operation.www_home.mode
      targets         = tencentcloud_teo_prefetch_task_operation.www_home.targets
    }
    rule_names      = {}
    expected_result = "The target URL is submitted for cache prefetch."
    next_lab        = "lab-16-resource-cleanup"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "ensure"
      resource  = "tencentcloud_teo_purge_task.www_home"
      name      = tencentcloud_teo_purge_task.www_home.job_id
      details = {
        purge_targets = join(",", tencentcloud_teo_purge_task.www_home.targets)
      }
    },
    {
      step      = 2
      operation = "create"
      resource  = "tencentcloud_teo_prefetch_task_operation.www_home"
      name      = tencentcloud_teo_prefetch_task_operation.www_home.job_id
      details = {
        prefetch_mode    = tencentcloud_teo_prefetch_task_operation.www_home.mode
        prefetch_targets = join(",", tencentcloud_teo_prefetch_task_operation.www_home.targets)
        job_id           = tencentcloud_teo_prefetch_task_operation.www_home.job_id
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-16-resource-cleanup"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-15-prefetch-urls"
    lab_success = tencentcloud_teo_prefetch_task_operation.www_home.job_id != "" ? "success" : "failed"
    next_lab    = "lab-16-resource-cleanup"
  }
}
