# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-04-ownership-verify"
}

output "zone_id" {
  description = "Verified EdgeOne zone ID."
  value       = tencentcloud_teo_zone.zone.id
}

output "ownership_verify_status" {
  description = "Domain ownership verification status."
  value       = tencentcloud_teo_ownership_verify.zone.status
}

output "ownership_verification" {
  description = "Remaining DNS verification information. Empty usually means verification has completed."
  value       = tencentcloud_teo_zone.zone.ownership_verification
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_ownership_verify.zone.status == "success" ? "success" : tencentcloud_teo_ownership_verify.zone.status
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab."
  value = {
    edgeone_zone          = tencentcloud_teo_zone.zone.zone_name
    zone_alias            = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
    ownership_verify_name = tencentcloud_teo_ownership_verify.zone.domain
    ownership_dns_record  = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id             = "lab-04-ownership-verify"
    action             = "Verify EdgeOne Zone ownership."
    execution_mode     = "apply"
    created_resources  = ["tencentcloud_teo_ownership_verify.zone"]
    optional_resources = ["tencentcloud_dnspod_record.ownership"]
    resource_names = {
      edgeone_zone          = tencentcloud_teo_zone.zone.zone_name
      ownership_verify_name = tencentcloud_teo_ownership_verify.zone.domain
      ownership_status      = tencentcloud_teo_ownership_verify.zone.status
      ownership_dns_record  = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
    }
    rule_names      = {}
    expected_result = "Zone ownership verification status is returned."
    next_lab        = "lab-05-domain-management"
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
        zone_id         = tencentcloud_teo_zone.zone.id
        alias_zone_name = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
        status          = tencentcloud_teo_zone.zone.status
      }
    },
    {
      step      = 2
      operation = var.auto_create_dnspod_records ? "create" : "manual"
      resource  = "tencentcloud_dnspod_record.ownership"
      name      = try(tencentcloud_dnspod_record.ownership[0].sub_domain, "manual ownership DNS record")
      details = {
        enabled   = var.auto_create_dnspod_records
        record_id = try(tencentcloud_dnspod_record.ownership[0].id, null)
        domain    = var.zone_name
      }
    },
    {
      step      = 3
      operation = "verify"
      resource  = "tencentcloud_teo_ownership_verify.zone"
      name      = tencentcloud_teo_ownership_verify.zone.domain
      details = {
        verify_id              = tencentcloud_teo_ownership_verify.zone.id
        ownership_verification = tencentcloud_teo_zone.zone.ownership_verification
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-05-domain-management"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-04-ownership-verify"
    lab_success = tencentcloud_teo_ownership_verify.zone.id != "" ? "success" : "failed"
    next_lab    = "lab-05-domain-management"
  }
}
