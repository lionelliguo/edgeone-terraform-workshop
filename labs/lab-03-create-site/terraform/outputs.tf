# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-03-create-site"
}

output "zone_id" {
  description = "Created EdgeOne zone ID."
  value       = tencentcloud_teo_zone.zone.id
}

output "zone_name" {
  description = "Created EdgeOne zone name."
  value       = tencentcloud_teo_zone.zone.zone_name
}

output "zone_status" {
  description = "Current EdgeOne zone status."
  value       = tencentcloud_teo_zone.zone.status
}

output "ownership_verification" {
  description = "DNS records required for domain ownership verification."
  value       = tencentcloud_teo_zone.zone.ownership_verification
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_zone.zone.id != "" ? "success" : "failed"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab."
  value = {
    edgeone_zone = tencentcloud_teo_zone.zone.zone_name
    zone_alias   = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-03-create-site"
    action            = "Create an EdgeOne Zone in partial mode."
    execution_mode    = "apply"
    created_resources = ["tencentcloud_teo_zone.zone"]
    resource_names = {
      edgeone_zone = tencentcloud_teo_zone.zone.zone_name
      zone_alias   = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
      zone_id      = tencentcloud_teo_zone.zone.id
      zone_status  = tencentcloud_teo_zone.zone.status
    }
    rule_names      = {}
    expected_result = "EdgeOne Zone exists and ownership verification information is available."
    next_lab        = "lab-04-ownership-verify"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "create"
      resource  = "tencentcloud_teo_zone.zone"
      name      = tencentcloud_teo_zone.zone.zone_name
      details = {
        zone_id         = tencentcloud_teo_zone.zone.id
        alias_zone_name = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
        area            = tencentcloud_teo_zone.zone.area
        type            = tencentcloud_teo_zone.zone.type
        status          = tencentcloud_teo_zone.zone.status
        plan_id         = var.plan_id
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-04-ownership-verify"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-03-create-site"
    lab_success = tencentcloud_teo_zone.zone.id != "" ? "success" : "failed"
    next_lab    = "lab-04-ownership-verify"
  }
}
