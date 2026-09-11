# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-06-cname-setup"
}

output "acceleration_domain" {
  description = "Business acceleration domain that should point to EdgeOne."
  value       = tencentcloud_teo_acceleration_domain.www.domain_name
}

output "edgeone_cname" {
  description = "EdgeOne CNAME target to configure in DNS."
  value       = tencentcloud_teo_acceleration_domain.www.cname
}

output "dnspod_cname_record_id" {
  description = "DNSPod CNAME record ID when auto_create_dnspod_records is enabled. Null means manual DNS mode."
  value       = try(tencentcloud_dnspod_record.www_cname[0].id, null)
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_acceleration_domain.www.cname != "" ? "success" : "failed"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab."
  value = {
    edgeone_zone          = tencentcloud_teo_zone.zone.zone_name
    zone_alias            = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
    ownership_verify_name = tencentcloud_teo_ownership_verify.zone.domain
    ownership_dns_record  = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
    acceleration_domain   = tencentcloud_teo_acceleration_domain.www.domain_name
    business_cname_record = try(tencentcloud_dnspod_record.www_cname[0].sub_domain, null)
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-06-cname-setup"
    action            = "Configure or display the CNAME setup required for the acceleration domain."
    execution_mode    = "apply"
    created_resources = var.auto_create_dnspod_records ? ["tencentcloud_dnspod_record.www_cname"] : []
    manual_resources  = var.auto_create_dnspod_records ? [] : ["External DNS CNAME record"]
    resource_names = {
      acceleration_domain   = tencentcloud_teo_acceleration_domain.www.domain_name
      edgeone_cname         = tencentcloud_teo_acceleration_domain.www.cname
      business_cname_record = try(tencentcloud_dnspod_record.www_cname[0].sub_domain, null)
    }
    rule_names      = {}
    expected_result = "The business domain points to the EdgeOne CNAME target, either automatically in DNSPod or manually in external DNS."
    next_lab        = "lab-07-ssl-certificate"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "ensure"
      resource  = "tencentcloud_teo_acceleration_domain.www"
      name      = tencentcloud_teo_acceleration_domain.www.domain_name
      details = {
        edgeone_cname = tencentcloud_teo_acceleration_domain.www.cname
      }
    },
    {
      step      = 2
      operation = var.auto_create_dnspod_records ? "create" : "manual"
      resource  = "tencentcloud_dnspod_record.www_cname"
      name      = try(tencentcloud_dnspod_record.www_cname[0].sub_domain, "manual business CNAME record")
      details = {
        enabled       = var.auto_create_dnspod_records
        record_id     = try(tencentcloud_dnspod_record.www_cname[0].id, null)
        record_type   = "CNAME"
        record_value  = tencentcloud_teo_acceleration_domain.www.cname
        business_host = tencentcloud_teo_acceleration_domain.www.domain_name
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-07-ssl-certificate"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-06-cname-setup"
    lab_success = tencentcloud_teo_acceleration_domain.www.cname != "" ? "success" : "failed"
    next_lab    = "lab-07-ssl-certificate"
  }
}
