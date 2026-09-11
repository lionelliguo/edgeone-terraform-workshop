# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-07-ssl-certificate"
}

output "https_host" {
  description = "Acceleration domain protected by the HTTPS certificate configuration."
  value       = tencentcloud_teo_acceleration_domain.www.domain_name
}

output "certificate_mode" {
  description = "Certificate mode configured for the acceleration domain."
  value       = var.certificate_mode
}

output "certificate_config_id" {
  description = "EdgeOne certificate configuration ID. Null means enable_certificate is false."
  value       = try(tencentcloud_teo_certificate_config.www[0].id, null)
}

output "lab_success" {
  description = "Lab completion status."
  value       = var.enable_certificate ? (try(tencentcloud_teo_certificate_config.www[0].id, "") != "" ? "success" : "failed") : "success"
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
    certificate_host      = try(tencentcloud_teo_certificate_config.www[0].host, null)
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-07-ssl-certificate"
    action            = "Configure SSL certificate for the acceleration domain."
    execution_mode    = "apply"
    created_resources = var.enable_certificate ? ["tencentcloud_teo_certificate_config.www"] : []
    resource_names = {
      https_host            = tencentcloud_teo_acceleration_domain.www.domain_name
      certificate_mode      = var.certificate_mode
      certificate_config_id = try(tencentcloud_teo_certificate_config.www[0].id, null)
    }
    rule_names      = {}
    expected_result = "HTTPS certificate configuration is attached to the acceleration domain."
    next_lab        = "lab-08-rule-engine"
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
      operation = var.enable_certificate ? "create" : "skip"
      resource  = "tencentcloud_teo_certificate_config.www"
      name      = try(tencentcloud_teo_certificate_config.www[0].host, tencentcloud_teo_acceleration_domain.www.domain_name)
      details = {
        enabled            = var.enable_certificate
        certificate_mode   = var.certificate_mode
        ssl_cert_id        = var.ssl_cert_id
        certificate_config = try(tencentcloud_teo_certificate_config.www[0].id, null)
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-08-rule-engine"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-07-ssl-certificate"
    lab_success = var.enable_certificate ? (try(tencentcloud_teo_certificate_config.www[0].id, "") != "" ? "success" : "failed") : "success"
    next_lab    = "lab-08-rule-engine"
  }
}
