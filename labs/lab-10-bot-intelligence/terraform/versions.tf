# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
terraform {
  required_version = ">= 1.10.0"

  backend "local" {
    path = "../../../shared/edgeone-workshop.tfstate"
  }

  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
    }
  }
}
