# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
variable "tencentcloud_secret_id" {
  description = "Tencent Cloud SecretId. Set this in credentials.auto.tfvars."
  type        = string
  sensitive   = true
}

variable "tencentcloud_secret_key" {
  description = "Tencent Cloud SecretKey. Set this in credentials.auto.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Tencent Cloud region used by the provider."
  type        = string
  default     = "ap-guangzhou"
}

variable "zone_name" {
  description = "EdgeOne site name, usually the apex domain, for example example.com."
  type        = string
}

variable "alias_zone_name" {
  description = "EdgeOne site alias shown in the console. Set this in terraform.tfvars. It must be different from zone_name."
  type        = string
}

variable "sub_domain" {
  description = "Subdomain prefix for the acceleration domain."
  type        = string
  default     = "www"
}

variable "plan_id" {
  description = "EdgeOne plan ID to bind to the zone."
  type        = string
}

variable "area" {
  description = "EdgeOne acceleration area. Common values: overseas, mainland, global."
  type        = string
  default     = "overseas"
}

variable "origin" {
  description = "Origin IP or domain."
  type        = string
}

variable "origin_type" {
  description = "Origin type. Common value: IP_DOMAIN."
  type        = string
  default     = "IP_DOMAIN"
}

variable "origin_host_header" {
  description = "Optional Host header for IP_DOMAIN origins. Leave null to use acceleration domain."
  type        = string
  default     = null
}

variable "auto_create_dnspod_records" {
  description = "Whether Terraform creates DNSPod records automatically. Use false when DNS is hosted elsewhere."
  type        = bool
  default     = false
}

variable "enable_certificate" {
  description = "Whether to configure certificate in this workshop."
  type        = bool
  default     = true
}

variable "certificate_mode" {
  description = "Certificate mode: eofreecert or sslcert."
  type        = string
  default     = "eofreecert"
}

variable "ssl_cert_id" {
  description = "SSL certificate ID when certificate_mode is sslcert."
  type        = string
  default     = null
}


variable "enable_l7_rules" {
  description = "Whether to create L7 acceleration rules."
  type        = bool
  default     = true
}

variable "enable_security_policy" {
  description = "Whether to create the sample Monitor-mode security policy."
  type        = bool
  default     = false
}

variable "enable_bot_intelligence" {
  description = "Whether to configure the Bot Intelligence sample in Lab 10 and later Labs."
  type        = bool
  default     = true
}

variable "enable_web_security_template" {
  description = "Whether to create and bind the Web Security Template sample in Lab 11 and later Labs."
  type        = bool
  default     = true
}


variable "enable_version_management" {
  description = "Whether to create an EdgeOne configuration group version in the version management Lab."
  type        = bool
  default     = true
}

variable "enable_version_deploy" {
  description = "Whether to deploy the newly created configuration group version. Lab 12 and later deploy to discovered Production and Staging environments by default."
  type        = bool
  default     = true
}

variable "version_group_id" {
  description = "Optional EdgeOne L7 configuration group ID. When null, Terraform tries to discover it from environments."
  type        = string
  default     = null
}

variable "version_env_id" {
  description = "Optional EdgeOne environment ID used only when enable_version_deploy is true."
  type        = string
  default     = null
}

variable "cleanup_confirm_destroy" {
  description = "Set to true only for Lab 16 terraform plan -destroy and terraform destroy commands. Normal apply is intentionally blocked."
  type        = bool
  default     = false
}
