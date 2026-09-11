# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-09-security-policy"
}

output "security_policy_enabled" {
  description = "Whether the workshop security policy resource is enabled."
  value       = var.enable_security_policy
}

output "security_policy_id" {
  description = "EdgeOne security policy configuration ID. Null means enable_security_policy is false."
  value       = try(tencentcloud_teo_security_policy_config.zone_default[0].id, null)
}

output "security_policy_entity" {
  description = "Security policy entity managed by this Lab. Null means enable_security_policy is false."
  value       = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
}

output "lab_success" {
  description = "Lab completion status."
  value       = var.enable_security_policy ? (try(tencentcloud_teo_security_policy_config.zone_default[0].id, "") != "" ? "success" : "failed") : "success"
}

output "security_custom_rule_names" {
  description = "Security custom rule names added by this Lab."
  value       = var.enable_security_policy ? ["monitor-curl-on-login"] : []
}

output "new_rule_names" {
  description = "All new rule names introduced by this Lab."
  value       = var.enable_security_policy ? ["monitor-curl-on-login"] : []
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
    security_policy       = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-09-security-policy"
    action            = "Configure the Zone Default security policy with a Monitor-mode custom rule."
    execution_mode    = "apply"
    created_resources = var.enable_security_policy ? ["tencentcloud_teo_security_policy_config.zone_default"] : []
    resource_names = {
      security_policy_enabled = var.enable_security_policy
      security_policy_id      = try(tencentcloud_teo_security_policy_config.zone_default[0].id, null)
      security_policy_entity  = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
    }
    rule_names = {
      security_custom_rules = var.enable_security_policy ? ["monitor-curl-on-login"] : []
      new_rules             = var.enable_security_policy ? ["monitor-curl-on-login"] : []
    }
    rule_actions = {
      monitor_curl_on_login = var.enable_security_policy ? "Monitor requests matching /login and curl user-agent" : "disabled"
    }
    expected_result = "Security policy is configured without blocking traffic."
    next_lab        = "lab-10-bot-intelligence"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "ensure"
      resource  = "tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache"
      name      = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
      details = {
        rule_name = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
        host      = tencentcloud_teo_acceleration_domain.www.domain_name
      }
    },
    {
      step      = 2
      operation = var.enable_security_policy ? "modify" : "skip"
      resource  = "tencentcloud_teo_security_policy_config.zone_default"
      name      = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, "ZoneDefaultPolicy")
      details = {
        policy_id    = try(tencentcloud_teo_security_policy_config.zone_default[0].id, null)
        policy_name  = "ZoneDefaultPolicy"
        custom_rules = join(",", var.enable_security_policy ? ["monitor-curl-on-login"] : [])
        action       = var.enable_security_policy ? "Monitor /login requests with curl user-agent" : "disabled"
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-10-bot-intelligence"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-09-security-policy"
    lab_success = var.enable_security_policy ? (try(tencentcloud_teo_security_policy_config.zone_default[0].id, "") != "" ? "success" : "failed") : "success"
    next_lab    = "lab-10-bot-intelligence"
  }
}
