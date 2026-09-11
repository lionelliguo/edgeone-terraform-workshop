# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-11-web-security-template"
}

output "web_security_template_enabled" {
  description = "Whether the Web Security Template sample is enabled."
  value       = var.enable_web_security_template
}

output "web_security_template_id" {
  description = "Created Web Security Template ID. Null means template creation is disabled."
  value       = try(tencentcloud_teo_web_security_template.workshop[0].id, null)
}

output "web_security_template_name" {
  description = "Created Web Security Template name."
  value       = var.enable_web_security_template ? tencentcloud_teo_web_security_template.workshop[0].template_name : null
}

output "web_security_template_bind_status" {
  description = "Security Template binding delivery status for the acceleration domain."
  value       = try(tencentcloud_teo_bind_security_template.www[0].status, null)
}

output "security_template_domain" {
  description = "Acceleration domain bound to the Web Security Template."
  value       = tencentcloud_teo_acceleration_domain.www.domain_name
}

output "lab_success" {
  description = "Lab completion status."
  value       = var.enable_web_security_template ? (try(tencentcloud_teo_bind_security_template.www[0].id, "") != "" ? "success" : "failed") : "success"
}

output "security_custom_rule_names" {
  description = "Web Security custom rule names in the template."
  value       = var.enable_web_security_template ? ["monitor-curl-on-login", "monitor-api-curl"] : []
}

output "bot_custom_rule_names" {
  description = "Bot custom rule names in the template."
  value       = var.enable_web_security_template ? ["bot-monitor-api-curl"] : []
}

output "rate_limiting_rule_names" {
  description = "Rate limiting rule names in the template."
  value       = var.enable_web_security_template ? ["login-single-ip-rate-limit"] : []
}

output "exception_rule_names" {
  description = "Exception rule names in the template."
  value       = var.enable_web_security_template ? ["health-check-skip-security-modules"] : []
}

output "new_rule_names" {
  description = "All rule names included in the Web Security Template by this Lab."
  value = var.enable_web_security_template ? [
    "monitor-curl-on-login",
    "bot-monitor-api-curl",
    "monitor-api-curl",
    "login-single-ip-rate-limit",
    "health-check-skip-security-modules"
  ] : []
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab."
  value = {
    edgeone_zone           = tencentcloud_teo_zone.zone.zone_name
    zone_alias             = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
    ownership_verify_name  = tencentcloud_teo_ownership_verify.zone.domain
    ownership_dns_record   = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
    acceleration_domain    = tencentcloud_teo_acceleration_domain.www.domain_name
    business_cname_record  = try(tencentcloud_dnspod_record.www_cname[0].sub_domain, null)
    certificate_host       = try(tencentcloud_teo_certificate_config.www[0].host, null)
    l7_rule                = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache.rule_name
    security_policy        = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
    web_security_template  = try(tencentcloud_teo_web_security_template.workshop[0].template_name, null)
    security_template_bind = tencentcloud_teo_acceleration_domain.www.domain_name
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-11-web-security-template"
    action            = "Create a Web Security Template and bind it to the www acceleration domain."
    execution_mode    = "apply"
    created_resources = var.enable_web_security_template ? ["tencentcloud_teo_web_security_template.workshop", "tencentcloud_teo_bind_security_template.www"] : []
    resource_names = {
      web_security_template_name = try(tencentcloud_teo_web_security_template.workshop[0].template_name, null)
      web_security_template_id   = try(tencentcloud_teo_web_security_template.workshop[0].id, null)
      bound_domain               = tencentcloud_teo_acceleration_domain.www.domain_name
      bind_status                = try(tencentcloud_teo_bind_security_template.www[0].status, null)
    }
    rule_names = {
      template_custom_rules     = var.enable_web_security_template ? ["monitor-curl-on-login", "monitor-api-curl"] : []
      bot_custom_rules          = var.enable_web_security_template ? ["bot-monitor-api-curl"] : []
      template_rate_limit_rules = var.enable_web_security_template ? ["login-single-ip-rate-limit"] : []
      template_exception_rules  = var.enable_web_security_template ? ["health-check-skip-security-modules"] : []
      new_rules                 = var.enable_web_security_template ? ["monitor-curl-on-login", "bot-monitor-api-curl", "monitor-api-curl", "login-single-ip-rate-limit", "health-check-skip-security-modules"] : []
    }
    rule_actions = {
      custom_rules   = "Monitor"
      bot_rules      = "Monitor"
      rate_limiting  = "Monitor after threshold"
      exception_rule = "Skip selected security modules for /healthz"
    }
    expected_result = "Web Security Template exists and is bound to the acceleration domain."
    next_lab        = "lab-12-version-management"
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
        carried_custom_rules = "monitor-curl-on-login"
        carried_bot_rules    = "bot-monitor-api-curl"
      }
    },
    {
      step      = 2
      operation = var.enable_web_security_template ? "create" : "skip"
      resource  = "tencentcloud_teo_web_security_template.workshop"
      name      = try(tencentcloud_teo_web_security_template.workshop[0].template_name, "workshop_www_security")
      details = {
        template_id        = try(tencentcloud_teo_web_security_template.workshop[0].id, null)
        custom_rules       = join(",", var.enable_web_security_template ? ["monitor-curl-on-login", "monitor-api-curl"] : [])
        bot_rules          = join(",", var.enable_web_security_template ? ["bot-monitor-api-curl"] : [])
        rate_limiting      = join(",", var.enable_web_security_template ? ["login-single-ip-rate-limit"] : [])
        exception_rules    = join(",", var.enable_web_security_template ? ["health-check-skip-security-modules"] : [])
        high_risk_bot_mode = var.enable_web_security_template ? "Monitor" : "disabled"
      }
    },
    {
      step      = 3
      operation = var.enable_web_security_template ? "bind" : "skip"
      resource  = "tencentcloud_teo_bind_security_template.www"
      name      = tencentcloud_teo_acceleration_domain.www.domain_name
      details = {
        template_name = try(tencentcloud_teo_web_security_template.workshop[0].template_name, null)
        bind_status   = try(tencentcloud_teo_bind_security_template.www[0].status, null)
        bound_domain  = tencentcloud_teo_acceleration_domain.www.domain_name
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-12-version-management"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-11-web-security-template"
    lab_success = var.enable_web_security_template ? (try(tencentcloud_teo_bind_security_template.www[0].id, "") != "" ? "success" : "failed") : "success"
    next_lab    = "lab-12-version-management"
  }
}
