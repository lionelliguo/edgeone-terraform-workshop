# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-10-bot-intelligence"
}

output "bot_intelligence_enabled" {
  description = "Whether Bot Intelligence configuration is enabled in this Lab."
  value       = var.enable_bot_intelligence
}

output "security_policy_id" {
  description = "Zone default security policy configuration ID. Null means Bot Intelligence is disabled."
  value       = try(tencentcloud_teo_security_policy_config.zone_default[0].id, null)
}

output "bot_high_risk_action" {
  description = "Action configured for high-risk bot requests."
  value       = var.enable_bot_intelligence ? "Monitor" : "disabled"
}

output "bot_custom_rule_name" {
  description = "Bot Management custom rule added by this Lab."
  value       = var.enable_bot_intelligence ? "bot-monitor-api-curl" : "disabled"
}

output "lab_success" {
  description = "Lab completion status."
  value       = var.enable_bot_intelligence ? (try(tencentcloud_teo_security_policy_config.zone_default[0].id, "") != "" ? "success" : "failed") : "success"
}

output "security_custom_rule_names" {
  description = "Security custom rule names managed in the zone default policy."
  value       = var.enable_bot_intelligence ? ["monitor-curl-on-login"] : []
}

output "bot_custom_rule_names" {
  description = "Bot custom rule names added by this Lab."
  value       = var.enable_bot_intelligence ? ["bot-monitor-api-curl"] : []
}

output "new_rule_names" {
  description = "All new rule names introduced by this Lab stage."
  value       = var.enable_bot_intelligence ? ["monitor-curl-on-login", "bot-monitor-api-curl"] : []
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
    lab_id            = "lab-10-bot-intelligence"
    action            = "Enable Bot Intelligence and add a Bot custom rule in Monitor mode."
    execution_mode    = "apply"
    created_resources = var.enable_bot_intelligence ? ["tencentcloud_teo_security_policy_config.zone_default"] : []
    resource_names = {
      bot_intelligence_enabled = var.enable_bot_intelligence
      security_policy_id       = try(tencentcloud_teo_security_policy_config.zone_default[0].id, null)
      security_policy_entity   = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
    }
    rule_names = {
      security_custom_rules = var.enable_bot_intelligence ? ["monitor-curl-on-login"] : []
      bot_custom_rules      = var.enable_bot_intelligence ? ["bot-monitor-api-curl"] : []
      new_rules             = var.enable_bot_intelligence ? ["monitor-curl-on-login", "bot-monitor-api-curl"] : []
    }
    rule_actions = {
      high_risk_bot        = var.enable_bot_intelligence ? "Monitor" : "disabled"
      bot_monitor_api_curl = var.enable_bot_intelligence ? "Monitor /api requests with curl user-agent" : "disabled"
    }
    expected_result = "Bot Intelligence is enabled in Monitor mode and bot traffic is observed without blocking."
    next_lab        = "lab-11-web-security-template"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "ensure"
      resource  = "tencentcloud_teo_security_policy_config.zone_default"
      name      = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, "ZoneDefaultPolicy")
      details = {
        existing_custom_rule = "monitor-curl-on-login"
      }
    },
    {
      step      = 2
      operation = var.enable_bot_intelligence ? "modify" : "skip"
      resource  = "tencentcloud_teo_security_policy_config.zone_default"
      name      = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, "ZoneDefaultPolicy")
      details = {
        policy_id             = try(tencentcloud_teo_security_policy_config.zone_default[0].id, null)
        bot_intelligence      = var.enable_bot_intelligence
        high_risk_bot_action  = var.enable_bot_intelligence ? "Monitor" : "disabled"
        bot_custom_rule_names = join(",", var.enable_bot_intelligence ? ["bot-monitor-api-curl"] : [])
        rule_action           = var.enable_bot_intelligence ? "Monitor /api curl requests" : "disabled"
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-11-web-security-template"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-10-bot-intelligence"
    lab_success = var.enable_bot_intelligence ? (try(tencentcloud_teo_security_policy_config.zone_default[0].id, "") != "" ? "success" : "failed") : "success"
    next_lab    = "lab-11-web-security-template"
  }
}
