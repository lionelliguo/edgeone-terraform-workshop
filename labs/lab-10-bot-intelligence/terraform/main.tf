# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
data "tencentcloud_teo_zone_available_plans" "available" {}

locals {
  acceleration_domain = "${var.sub_domain}.${var.zone_name}"
}

resource "tencentcloud_teo_zone" "zone" {
  zone_name       = var.zone_name
  type            = "partial"
  area            = var.area
  alias_zone_name = var.alias_zone_name == var.zone_name ? "${var.zone_name}-workshop" : var.alias_zone_name
  paused          = false
  plan_id         = var.plan_id

  tags = {
    createdBy = "terraform"
    workshop  = "edgeone"
  }


  lifecycle {
    ignore_changes = all
  }
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

resource "tencentcloud_teo_l7_acc_rule_v2" "www_https_and_cache" {
  zone_id     = tencentcloud_teo_zone.zone.id
  rule_name   = "workshop-www-https-cache"
  description = ["Managed by Terraform workshop"]
  status      = "enable"

  branches {
    condition = "$${http.request.host} in ['${local.acceleration_domain}']"

    actions {
      name = "ForceRedirectHTTPS"
      force_redirect_https_parameters {
        switch               = "on"
        redirect_status_code = 301
      }
    }

    sub_rules {
      description = ["Cache static assets for 30 days"]
      branches {
        condition = "lower($${http.request.file_extension}) in ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp', 'css', 'js']"
        actions {
          name = "Cache"
          cache_parameters {
            custom_time {
              switch               = "on"
              cache_time           = 2592000
              ignore_cache_control = "off"
            }
          }
        }
      }
    }

    sub_rules {
      description = ["Do not cache dynamic pages"]
      branches {
        condition = "lower($${http.request.file_extension}) in ['php', 'jsp', 'asp', 'aspx']"
        actions {
          name = "Cache"
          cache_parameters {
            no_cache {
              switch = "on"
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

        ip_reputation {
          enabled = "off"
          ip_reputation_group {}
        }

        known_bot_categories {}
        search_engine_bots {}
        source_idc {}
      }
    }
  }

  depends_on = [tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache]
}
