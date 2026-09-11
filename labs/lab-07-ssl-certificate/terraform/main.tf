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

  depends_on = [
    tencentcloud_teo_acceleration_domain.www,
    tencentcloud_dnspod_record.www_cname
  ]
}
