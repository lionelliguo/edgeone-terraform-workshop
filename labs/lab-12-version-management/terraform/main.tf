# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
data "tencentcloud_teo_zone_available_plans" "available" {}

locals {
  acceleration_domain = "${var.sub_domain}.${var.zone_name}"
}

resource "time_sleep" "before_version_management_enable" {
  count = var.enable_version_management ? 1 : 0

  create_duration = "300s"

  depends_on = [terraform_data.lab_sequence_guard]
}

resource "tencentcloud_teo_zone" "zone" {
  zone_name       = var.zone_name
  type            = "partial"
  area            = var.area
  alias_zone_name = var.alias_zone_name == var.zone_name ? "${var.zone_name}-workshop" : var.alias_zone_name
  paused          = false
  plan_id         = var.plan_id

  work_mode_infos {
    config_group_type = "l7_acceleration"
    work_mode         = "version_control"
  }

  work_mode_infos {
    config_group_type = "edge_functions"
    work_mode         = "immediate_effect"
  }

  work_mode_infos {
    config_group_type = "web_security"
    work_mode         = "immediate_effect"
  }

  tags = {
    createdBy = "terraform"
    workshop  = "edgeone"
  }


  lifecycle {
    ignore_changes = [paused]
  }

  depends_on = [time_sleep.before_version_management_enable]
}

resource "tencentcloud_dnspod_record" "ownership" {
  count = var.auto_create_dnspod_records ? 1 : 0

  domain      = var.zone_name
  record_type = tencentcloud_teo_zone.zone.ownership_verification[0].dns_verification[0].record_type
  record_line = "Default"
  value       = tencentcloud_teo_zone.zone.ownership_verification[0].dns_verification[0].record_value
  sub_domain  = tencentcloud_teo_zone.zone.ownership_verification[0].dns_verification[0].subdomain


  lifecycle {
    ignore_changes = all
  }
}

resource "tencentcloud_teo_ownership_verify" "zone" {
  domain = var.zone_name


  lifecycle {
    ignore_changes = all
  }
  depends_on = [tencentcloud_dnspod_record.ownership]
}

resource "tencentcloud_teo_acceleration_domain" "www" {
  zone_id     = tencentcloud_teo_zone.zone.id
  domain_name = local.acceleration_domain

  origin_info {
    origin      = var.origin
    origin_type = var.origin_type
    host_header = var.origin_host_header
  }

  status            = "online"
  origin_protocol   = "FOLLOW"
  http_origin_port  = 80
  https_origin_port = 443
  ipv6_status       = "follow"


  lifecycle {
    ignore_changes = all
  }
  depends_on = [tencentcloud_teo_ownership_verify.zone]
}

resource "tencentcloud_dnspod_record" "www_cname" {
  count = var.auto_create_dnspod_records ? 1 : 0

  domain      = var.zone_name
  record_type = "CNAME"
  record_line = "Default"
  value       = tencentcloud_teo_acceleration_domain.www.cname
  sub_domain  = var.sub_domain


  lifecycle {
    ignore_changes = all
  }
}

resource "tencentcloud_teo_certificate_config" "www" {
  count = var.enable_certificate ? 1 : 0

  zone_id = tencentcloud_teo_zone.zone.id
  host    = tencentcloud_teo_acceleration_domain.www.domain_name
  mode    = var.certificate_mode

  dynamic "server_cert_info" {
    for_each = var.certificate_mode == "sslcert" && var.ssl_cert_id != null ? [1] : []
    content {
      cert_id = var.ssl_cert_id
    }
  }


  lifecycle {
    ignore_changes = all
  }
  depends_on = [
    tencentcloud_teo_acceleration_domain.www,
    tencentcloud_dnspod_record.www_cname
  ]
}

removed {
  from = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache

  lifecycle {
    destroy = false
  }
}

resource "tencentcloud_teo_security_policy_config" "zone_default" {
  count = var.enable_bot_intelligence ? 1 : 0

  zone_id = tencentcloud_teo_zone.zone.id
  entity  = "ZoneDefaultPolicy"

  security_policy {
    custom_rules {
      precise_match_rules {
        name      = "monitor-curl-on-login"
        condition = "$${http.request.uri.path} contain ['/login'] and $${http.request.headers['user-agent']} contain ['curl']"
        enabled   = "on"
        priority  = 50
        action {
          name = "Monitor"
        }
      }
    }

    bot_management {
      enabled = "on"

      custom_rules {
        name      = "bot-monitor-api-curl"
        condition = "$${http.request.uri.path} contain ['/api'] and $${http.request.headers['user-agent']} contain ['curl']"
        enabled   = "on"
        priority  = 40
        action {
          weight = 100
          action {
            name = "Monitor"
          }
        }
      }

      basic_bot_settings {
        bot_intelligence {
          enabled = "on"
          bot_ratings {
            high_risk_bot_requests_action {
              name = "Monitor"
            }
            likely_bot_requests_action {
              name = "Monitor"
            }
            verified_bot_requests_action {
              name = "Allow"
            }
            human_requests_action {
              name = "Allow"
            }
          }
        }
      }
    }
  }


  lifecycle {
    ignore_changes = all
  }
  depends_on = [tencentcloud_teo_acceleration_domain.www]
}

resource "tencentcloud_teo_web_security_template" "workshop" {
  count = var.enable_web_security_template ? 1 : 0

  zone_id       = tencentcloud_teo_zone.zone.id
  template_name = "workshop_www_security"

  security_policy {
    bot_management {
      enabled = "on"

      custom_rules {
        rules {
          name      = "bot-monitor-api-curl"
          condition = "$${http.request.uri.path} contain ['/api'] and $${http.request.headers['user-agent']} contain ['curl']"
          enabled   = "on"
          priority  = 40
          action {
            weight = 100
            security_action {
              name = "Monitor"
            }
          }
        }
      }

      basic_bot_settings {
        bot_intelligence {
          enabled = "on"
          bot_ratings {
            high_risk_bot_requests_action {
              name = "Monitor"
            }
            likely_bot_requests_action {
              name = "Monitor"
            }
            verified_bot_requests_action {
              name = "Allow"
            }
            human_requests_action {
              name = "Allow"
            }
          }
        }
      }
    }

    custom_rules {
      rules {
        name      = "monitor-curl-on-login"
        condition = "$${http.request.uri.path} contain ['/login'] and $${http.request.headers['user-agent']} contain ['curl']"
        enabled   = "on"
        priority  = 40
        rule_type = "PreciseMatchRule"
        action {
          name = "Monitor"
        }
      }

      rules {
        name      = "monitor-api-curl"
        condition = "$${http.request.uri.path} contain ['/api'] and $${http.request.headers['user-agent']} contain ['curl']"
        enabled   = "on"
        priority  = 50
        rule_type = "PreciseMatchRule"
        action {
          name = "Monitor"
        }
      }
    }

    rate_limiting_rules {
      rules {
        name                  = "login-single-ip-rate-limit"
        condition             = "$${http.request.uri.path} contain ['/login']"
        count_by              = ["http.request.ip"]
        counting_period       = "60s"
        max_request_threshold = 300
        action_duration       = "30m"
        enabled               = "on"
        priority              = 50
        action {
          name = "Monitor"
        }
      }
    }

    exception_rules {
      rules {
        name                               = "health-check-skip-security-modules"
        condition                          = "$${http.request.uri.path} in ['/healthz']"
        enabled                            = "on"
        skip_scope                         = "WebSecurityModules"
        skip_option                        = "SkipOnAllRequestFields"
        managed_rule_groups_for_exception  = []
        managed_rules_for_exception        = []
        web_security_modules_for_exception = ["websec-mod-custom-rules", "websec-mod-rate-limiting", "websec-mod-bot"]
      }
    }
  }

  lifecycle {
    ignore_changes = all
  }
  depends_on = [tencentcloud_teo_acceleration_domain.www]
}

resource "time_sleep" "after_security_template_unbind" {
  count = var.enable_web_security_template ? 1 : 0

  destroy_duration = "90s"

  depends_on = [tencentcloud_teo_web_security_template.workshop]
}

resource "tencentcloud_teo_bind_security_template" "www" {
  count = var.enable_web_security_template ? 1 : 0

  zone_id     = tencentcloud_teo_zone.zone.id
  template_id = element(split("#", tencentcloud_teo_web_security_template.workshop[0].id), 1)
  entity      = tencentcloud_teo_acceleration_domain.www.domain_name
  over_write  = true

  lifecycle {
    ignore_changes = all
  }
  depends_on = [time_sleep.after_security_template_unbind]
}
resource "time_sleep" "after_version_management_enable" {
  count = var.enable_version_management ? 1 : 0

  create_duration = "300s"

  depends_on = [tencentcloud_teo_zone.zone]
}

data "tencentcloud_teo_export_zone_config" "l7_acceleration" {
  count = var.enable_version_management ? 1 : 0

  zone_id = tencentcloud_teo_zone.zone.id
  types   = ["L7AccelerationConfig"]

  depends_on = [time_sleep.after_version_management_enable]
}

data "tencentcloud_teo_environments" "zone" {
  count = var.enable_version_management ? 1 : 0

  zone_id = tencentcloud_teo_zone.zone.id

  depends_on = [time_sleep.after_version_management_enable]
}

locals {
  version_management_env_infos = var.enable_version_management ? coalesce(data.tencentcloud_teo_environments.zone[0].env_infos, []) : []
  version_management_l7_groups = flatten([
    for env in local.version_management_env_infos : [
      for version_info in coalesce(env.current_config_group_version_infos, []) : version_info
      if lower(version_info.group_type) == "l7_acceleration"
    ]
  ])
  version_management_discovered_env_id      = try(local.version_management_env_infos[0].env_id, null)
  version_management_discovered_prod_env_id = try([for env in local.version_management_env_infos : env.env_id if lower(env.env_type) == "production"][0], null)
  version_management_discovered_stage_env_id = try([
    for env in local.version_management_env_infos : env.env_id
    if lower(env.env_type) == "staging"
  ][0], null)
  version_management_env_id                 = var.version_env_id != null ? var.version_env_id : local.version_management_discovered_env_id
  version_management_discovered_l7_group_id = try(local.version_management_l7_groups[0].group_id, null)
  version_management_l7_group_id            = var.version_group_id != null ? var.version_group_id : local.version_management_discovered_l7_group_id
  version_management_can_version            = var.enable_version_management && local.version_management_l7_group_id != null
  version_management_deploy_env_ids = var.version_env_id != null ? {
    custom = var.version_env_id
    } : {
    production = local.version_management_discovered_prod_env_id
    staging    = local.version_management_discovered_stage_env_id
  }
  version_management_deploy_targets = var.enable_version_deploy ? local.version_management_deploy_env_ids : {}
}

resource "tencentcloud_teo_config_group_version" "workshop_l7" {
  count = var.enable_version_management ? 1 : 0

  zone_id     = tencentcloud_teo_zone.zone.id
  group_id    = local.version_management_l7_group_id
  content     = data.tencentcloud_teo_export_zone_config.l7_acceleration[0].content
  description = "workshop l7 version"

  depends_on = [data.tencentcloud_teo_export_zone_config.l7_acceleration, data.tencentcloud_teo_environments.zone]
}

resource "tencentcloud_teo_deploy_config_group_version" "workshop_l7_staging" {
  count = var.enable_version_management && var.enable_version_deploy && var.version_env_id == null ? 1 : 0

  zone_id     = tencentcloud_teo_zone.zone.id
  env_id      = local.version_management_discovered_stage_env_id
  description = "deploy workshop l7 version to staging"

  config_group_version_infos {
    version_id = tencentcloud_teo_config_group_version.workshop_l7[0].version_id
  }

  timeouts {
    create = "20m"
  }

  depends_on = [tencentcloud_teo_config_group_version.workshop_l7, time_sleep.after_version_management_enable]
}

resource "tencentcloud_teo_deploy_config_group_version" "workshop_l7_production" {
  count = var.enable_version_management && var.enable_version_deploy && var.version_env_id == null ? 1 : 0

  zone_id     = tencentcloud_teo_zone.zone.id
  env_id      = local.version_management_discovered_prod_env_id
  description = "deploy workshop l7 version to production"

  config_group_version_infos {
    version_id = tencentcloud_teo_config_group_version.workshop_l7[0].version_id
  }

  timeouts {
    create = "20m"
  }

  depends_on = [tencentcloud_teo_deploy_config_group_version.workshop_l7_staging]
}

resource "tencentcloud_teo_deploy_config_group_version" "workshop_l7_custom" {
  count = var.enable_version_management && var.enable_version_deploy && var.version_env_id != null ? 1 : 0

  zone_id     = tencentcloud_teo_zone.zone.id
  env_id      = var.version_env_id
  description = "deploy workshop l7 version to custom"

  config_group_version_infos {
    version_id = tencentcloud_teo_config_group_version.workshop_l7[0].version_id
  }

  timeouts {
    create = "20m"
  }

  depends_on = [tencentcloud_teo_config_group_version.workshop_l7, time_sleep.after_version_management_enable]
}

moved {
  from = tencentcloud_teo_deploy_config_group_version.workshop_l7["staging"]
  to   = tencentcloud_teo_deploy_config_group_version.workshop_l7_staging[0]
}

moved {
  from = tencentcloud_teo_deploy_config_group_version.workshop_l7["production"]
  to   = tencentcloud_teo_deploy_config_group_version.workshop_l7_production[0]
}
