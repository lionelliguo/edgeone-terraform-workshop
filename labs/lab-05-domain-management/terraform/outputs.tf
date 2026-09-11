# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-05-domain-management"
}

output "zone_id" {
  description = "EdgeOne zone ID used by the acceleration domain."
  value       = tencentcloud_teo_zone.zone.id
}

output "acceleration_domain" {
  description = "Created business acceleration domain."
  value       = tencentcloud_teo_acceleration_domain.www.domain_name
}

output "edgeone_cname" {
  description = "EdgeOne CNAME target for the acceleration domain."
  value       = tencentcloud_teo_acceleration_domain.www.cname
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_acceleration_domain.www.domain_name != "" && tencentcloud_teo_acceleration_domain.www.cname != "" ? "success" : "failed"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab."
  value = {
    edgeone_zone          = tencentcloud_teo_zone.zone.zone_name
    zone_alias            = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
    ownership_verify_name = tencentcloud_teo_ownership_verify.zone.domain
    ownership_dns_record  = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
    acceleration_domain   = tencentcloud_teo_acceleration_domain.www.domain_name
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-05-domain-management"
    action            = "Create the www EdgeOne acceleration domain and origin configuration."
    execution_mode    = "apply"
    created_resources = ["tencentcloud_teo_acceleration_domain.www"]
    resource_names = {
      edgeone_zone        = tencentcloud_teo_zone.zone.zone_name
      acceleration_domain = tencentcloud_teo_acceleration_domain.www.domain_name
      edgeone_cname       = tencentcloud_teo_acceleration_domain.www.cname
      origin              = var.origin
      origin_type         = var.origin_type
    }
    rule_names      = {}
    expected_result = "Business acceleration domain exists and returns an EdgeOne CNAME target."
    next_lab        = "lab-06-cname-setup"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "ensure"
      resource  = "tencentcloud_teo_zone.zone"
      name      = tencentcloud_teo_zone.zone.zone_name
      details = {
        zone_id = tencentcloud_teo_zone.zone.id
        status  = tencentcloud_teo_zone.zone.status
      }
    },
    {
      step      = 2
      operation = "verify"
      resource  = "tencentcloud_teo_ownership_verify.zone"
      name      = tencentcloud_teo_ownership_verify.zone.domain
      details = {
        verify_id = tencentcloud_teo_ownership_verify.zone.id
      }
    },
    {
      step      = 3
      operation = "create"
      resource  = "tencentcloud_teo_acceleration_domain.www"
      name      = tencentcloud_teo_acceleration_domain.www.domain_name
      details = {
        domain_id          = tencentcloud_teo_acceleration_domain.www.id
        edgeone_cname      = tencentcloud_teo_acceleration_domain.www.cname
        origin             = var.origin
        origin_type        = var.origin_type
        origin_host_header = var.origin_host_header
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-06-cname-setup"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-05-domain-management"
    lab_success = tencentcloud_teo_acceleration_domain.www.id != "" ? "success" : "failed"
    next_lab    = "lab-06-cname-setup"
  }
}
