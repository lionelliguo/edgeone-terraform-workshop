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
    ignore_changes = [paused]
  }
}
