# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-16-resource-cleanup"
}

output "lab_success" {
  description = "Lab completion status before destroy. After destroy, no outputs remain because the state is removed."
  value       = "success"
}

locals {
  deploy_record_id = var.version_env_id != null ? {
    custom = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_custom[0].record_id, null)
    } : {
    staging    = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_staging[0].record_id, null)
    production = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_production[0].record_id, null)
  }

  deploy_env_id = var.version_env_id != null ? {
    custom = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_custom[0].env_id, null)
    } : {
    staging    = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_staging[0].env_id, null)
    production = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_production[0].env_id, null)
  }

  deploy_status = var.version_env_id != null ? {
    custom = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_custom[0].status, null)
    } : {
    staging    = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_staging[0].status, null)
    production = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_production[0].status, null)
  }

  updated_deploy_record_id = var.version_env_id != null ? {
    custom = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_update_custom[0].record_id, null)
    } : {
    staging    = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_update_staging[0].record_id, null)
    production = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_update_production[0].record_id, null)
  }

  updated_deploy_status = var.version_env_id != null ? {
    custom = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_update_custom[0].status, null)
    } : {
    staging    = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_update_staging[0].status, null)
    production = try(tencentcloud_teo_deploy_config_group_version.workshop_l7_update_production[0].status, null)
  }

  cleanup_resource_names = {
    version_config_type          = local.cleanup_include_version_management ? "L7AccelerationConfig" : "disabled"
    version_control_work_mode    = "version_control"
    edgeone_zone                 = tencentcloud_teo_zone.zone.zone_name
    zone_alias                   = coalesce(tencentcloud_teo_zone.zone.alias_zone_name, var.alias_zone_name)
    ownership_verify_name        = tencentcloud_teo_ownership_verify.zone.domain
    ownership_dns_record         = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
    acceleration_domain          = tencentcloud_teo_acceleration_domain.www.domain_name
    cname_dns_record             = try(tencentcloud_dnspod_record.www_cname[0].sub_domain, null)
    certificate_host             = try(tencentcloud_teo_certificate_config.www[0].host, null)
    security_policy              = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
    web_security_template        = try(tencentcloud_teo_web_security_template.workshop[0].template_name, null)
    security_template_bind       = try(tencentcloud_teo_bind_security_template.www[0].entity, null)
    version_group_id             = local.cleanup_include_version_management ? local.version_management_l7_group_id : null
    discovered_version_group_id  = local.cleanup_include_version_management ? local.version_management_discovered_l7_group_id : null
    discovered_version_env_id    = local.cleanup_include_version_management ? local.version_management_discovered_env_id : null
    discovered_production_env_id = local.cleanup_include_version_management ? local.version_management_discovered_prod_env_id : null
    discovered_staging_env_id    = local.cleanup_include_version_management ? local.version_management_discovered_stage_env_id : null
    version_deploy_env_ids       = local.cleanup_include_version_management ? local.version_management_deploy_env_ids : {}
    version_resource_status      = local.cleanup_include_version_management ? (try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null) != null ? "created" : "pending_apply") : "disabled"
    config_group_version_id      = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null)
    config_group_version_number  = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_number, null)
    deploy_config_group_records  = local.deploy_record_id
    deploy_config_group_env_ids  = local.deploy_env_id
    deploy_config_group_statuses = local.deploy_status
    updated_version_description  = "Managed by Terraform workshop - updated version"
    updated_rule_engine_rule     = local.update_version_rule_engine_rule_name
    updated_version_status       = local.cleanup_include_version_management ? (try(tencentcloud_teo_config_group_version.workshop_l7_update[0].version_id, null) != null ? "created" : "pending_apply") : "disabled"
    updated_version_id           = try(tencentcloud_teo_config_group_version.workshop_l7_update[0].version_id, null)
    updated_version_number       = try(tencentcloud_teo_config_group_version.workshop_l7_update[0].version_number, null)
    updated_deploy_records       = local.updated_deploy_record_id
    updated_deploy_statuses      = local.updated_deploy_status
    purge_task_target            = try(one(tencentcloud_teo_purge_task.www_home.targets), null)
    prefetch_task_target         = try(one(tencentcloud_teo_prefetch_task_operation.www_home.targets), null)
    rule_names = {
      l7_rules                  = ["workshop-www-https-cache", local.update_version_rule_engine_rule_name]
      security_custom_rules     = ["monitor-curl-on-login"]
      bot_custom_rules          = ["bot-monitor-api-curl"]
      template_custom_rules     = ["monitor-curl-on-login", "monitor-api-curl"]
      template_rate_limit_rules = ["login-single-ip-rate-limit"]
      template_exception_rules  = ["health-check-skip-security-modules"]
    }
    exported_configuration_scope = "L7AccelerationConfig"
  }
}

output "cleanup_resource_names" {
  description = "Workshop resource names targeted for cleanup by this Lab before destroy, including rule names."
  value       = local.cleanup_resource_names
}

output "created_resource_names" {
  description = "Backward-compatible alias for cleanup_resource_names in this cleanup Lab."
  value       = local.cleanup_resource_names
}

output "current_execution" {
  description = "Human-readable summary of what this Lab will destroy during cleanup. After successful destroy, outputs are removed from state."
  value = {
    lab_id            = "lab-16-resource-cleanup"
    action            = "Destroy workshop-managed EdgeOne, DNSPod, security, version-management, cache operation, and state guard resources."
    execution_mode    = "destroy-only"
    required_commands = ["terraform plan -destroy -var=cleanup_confirm_destroy=true", "terraform destroy -var=cleanup_confirm_destroy=true"]
    cleanup_targets   = local.cleanup_resource_names
    rule_names        = local.cleanup_resource_names.rule_names
    destroy_notes     = ["Normal terraform apply is blocked", "Web Security Template deletion can require a retry after EdgeOne releases the template binding"]
    expected_result   = "After successful destroy, Terraform state is empty and no outputs remain."
    restart_from      = "lab-01-provider-init"
  }
}
output "execution_steps" {
  description = "Ordered resource destroy details for this cleanup Lab."
  value = [
    {
      step      = 1
      operation = "destroy"
      resource  = "cache operation resources"
      name      = "purge and prefetch tasks"
      details = {
        purge_task_target    = try(one(tencentcloud_teo_purge_task.www_home.targets), null)
        prefetch_task_target = try(one(tencentcloud_teo_prefetch_task_operation.www_home.targets), null)
      }
    },
    {
      step      = 2
      operation = "destroy"
      resource  = "security template and policies"
      name      = try(tencentcloud_teo_web_security_template.workshop[0].template_name, "workshop_www_security")
      details = {
        security_policy        = try(tencentcloud_teo_security_policy_config.zone_default[0].entity, null)
        web_security_template  = try(tencentcloud_teo_web_security_template.workshop[0].template_name, null)
        security_template_bind = try(tencentcloud_teo_bind_security_template.www[0].entity, null)
        security_custom_rules  = "monitor-curl-on-login,monitor-api-curl"
        bot_custom_rules       = "bot-monitor-api-curl"
        rate_limiting_rules    = "login-single-ip-rate-limit"
        exception_rules        = "health-check-skip-security-modules"
      }
    },
    {
      step      = 3
      operation = "destroy"
      resource  = "version management resources"
      name      = local.cleanup_include_version_management ? local.version_management_l7_group_id : "disabled"
      details = {
        config_group_version_id = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null)
        updated_version_id      = try(tencentcloud_teo_config_group_version.workshop_l7_update[0].version_id, null)
        deploy_records          = jsonencode(local.deploy_record_id)
        updated_deploy_records  = jsonencode(local.updated_deploy_record_id)
        rule_engine_rules       = join(",", ["workshop-www-https-cache", local.update_version_rule_engine_rule_name])
      }
    },
    {
      step      = 4
      operation = "destroy"
      resource  = "EdgeOne site, domain, DNS and certificate resources"
      name      = tencentcloud_teo_zone.zone.zone_name
      details = {
        zone_id              = tencentcloud_teo_zone.zone.id
        acceleration_domain  = tencentcloud_teo_acceleration_domain.www.domain_name
        cname_dns_record     = try(tencentcloud_dnspod_record.www_cname[0].sub_domain, null)
        ownership_dns_record = try(tencentcloud_dnspod_record.ownership[0].sub_domain, null)
        certificate_host     = try(tencentcloud_teo_certificate_config.www[0].host, null)
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after cleanup succeeds."
  value       = "lab-01-provider-init"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-16-resource-cleanup"
    lab_success = "success"
    next_lab    = "lab-01-provider-init"
  }
}
