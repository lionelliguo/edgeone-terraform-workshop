# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-08-rule-engine"
}

output "acceleration_domain" {
  description = "Acceleration domain matched by the L7 rule."
  value       = tencentcloud_teo_acceleration_domain.www.domain_name
}

output "l7_rule_id" {
  description = "Created EdgeOne L7 acceleration rule ID."
  value       = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.id
}

output "l7_rule_name" {
  description = "Created EdgeOne L7 acceleration rule name."
  value       = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
}

output "lab_success" {
  description = "Lab completion status."
  value       = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.id != "" ? "success" : "failed"
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
    l7_rule               = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-08-rule-engine"
    action            = "Create a Rule Engine rule for HTTPS redirect and cache behavior."
    execution_mode    = "apply"
    created_resources = ["tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache"]
    resource_names = {
      acceleration_domain = tencentcloud_teo_acceleration_domain.www.domain_name
      l7_rule_id          = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.id
      l7_rule_name        = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
    }
    rule_names = {
      l7_rules  = [tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name]
      sub_rules = ["Cache static assets for 30 days", "Do not cache dynamic pages"]
    }
    rule_actions = {
      force_https_redirect = "ForceRedirectHTTPS 301"
      static_cache         = "Cache static assets for 30 days"
      dynamic_no_cache     = "Do not cache php/jsp/asp/aspx pages"
    }
    expected_result = "Rule Engine applies HTTPS redirect and cache policies to the acceleration domain."
    next_lab        = "lab-09-security-policy"
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
      operation = var.enable_l7_rules ? "create" : "skip"
      resource  = "tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache"
      name      = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
      details = {
        rule_id   = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.id
        rule_name = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
        host      = tencentcloud_teo_acceleration_domain.www.domain_name
        actions   = "HTTPS redirect and cache behavior"
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-09-security-policy"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-08-rule-engine"
    lab_success = var.enable_l7_rules ? (tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.id != "" ? "success" : "failed") : "success"
    next_lab    = "lab-09-security-policy"
  }
}
