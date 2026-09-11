# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
output "lab_id" {
  description = "Workshop Lab ID that completed most recently in the shared state."
  value       = "lab-12-version-management"
}

output "version_management_enabled" {
  description = "Whether this Lab creates an EdgeOne configuration group version."
  value       = var.enable_version_management
}

output "version_deploy_enabled" {
  description = "Whether this Lab deploys the newly created configuration group version."
  value       = var.enable_version_deploy
}

output "version_config_type" {
  description = "Configuration type exported for version management."
  value       = var.enable_version_management ? "L7AccelerationConfig" : "disabled"
}

output "version_control_work_mode" {
  description = "Work mode configured for the L7 acceleration configuration group."
  value       = "version_control"
}

output "version_env_id" {
  description = "Backward-compatible effective EdgeOne environment ID. For multi-environment deployment, use version_deploy_env_ids."
  value       = var.enable_version_management ? local.version_management_env_id : null
}

output "discovered_version_env_id" {
  description = "First EdgeOne environment ID discovered from the site after version control is enabled."
  value       = var.enable_version_management ? local.version_management_discovered_env_id : null
}

output "discovered_production_env_id" {
  description = "Production environment ID discovered from the site after version control is enabled."
  value       = var.enable_version_management ? local.version_management_discovered_prod_env_id : null
}

output "discovered_staging_env_id" {
  description = "Staging environment ID discovered from the site after version control is enabled."
  value       = var.enable_version_management ? local.version_management_discovered_stage_env_id : null
}

output "version_deploy_env_ids" {
  description = "Environment IDs targeted by version deployment. Defaults to production and staging."
  value       = var.enable_version_management ? local.version_management_deploy_env_ids : {}
}

output "version_group_id" {
  description = "Effective L7 acceleration configuration group ID used to create the version. Uses version_group_id first, then the discovered L7 group ID."
  value       = var.enable_version_management ? local.version_management_l7_group_id : null
}

output "discovered_version_group_id" {
  description = "L7 acceleration configuration group ID discovered from the site after version control is enabled."
  value       = var.enable_version_management ? local.version_management_discovered_l7_group_id : null
}

output "version_resource_status" {
  description = "Whether the configuration group version resource was created, skipped, or disabled."
  value       = var.enable_version_management ? (try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null) != null ? "created" : "pending_apply") : "disabled"
}

output "config_group_version_id" {
  description = "Created EdgeOne configuration group version ID."
  value       = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null)
}

output "config_group_version_number" {
  description = "Created EdgeOne configuration group version number."
  value       = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_number, null)
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
}

output "deploy_record_id" {
  description = "Deploy record IDs by environment when enable_version_deploy is true."
  value       = local.deploy_record_id
}

output "deploy_status" {
  description = "Deploy statuses by environment when enable_version_deploy is true."
  value       = local.deploy_status
}

output "lab_success" {
  description = "Lab completion status."
  value       = var.enable_version_management ? (data.tencentcloud_teo_export_zone_config.l7_acceleration[0].content != "" ? "success" : "failed") : "success"
}

output "created_resource_names" {
  description = "Resource names created or managed by this Lab. Earlier resources are dependencies only."
  value = {
    version_config_type          = var.enable_version_management ? "L7AccelerationConfig" : "disabled"
    version_control_work_mode    = "version_control"
    version_group_id             = var.enable_version_management ? local.version_management_l7_group_id : null
    discovered_version_group_id  = var.enable_version_management ? local.version_management_discovered_l7_group_id : null
    discovered_version_env_id    = var.enable_version_management ? local.version_management_discovered_env_id : null
    discovered_production_env_id = var.enable_version_management ? local.version_management_discovered_prod_env_id : null
    discovered_staging_env_id    = var.enable_version_management ? local.version_management_discovered_stage_env_id : null
    version_deploy_env_ids       = var.enable_version_management ? local.version_management_deploy_env_ids : {}
    version_resource_status      = var.enable_version_management ? (try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null) != null ? "created" : "pending_apply") : "disabled"
    config_group_version_id      = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null)
    config_group_version_number  = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_number, null)
    deploy_config_group_records  = local.deploy_record_id
    deploy_config_group_env_ids  = local.deploy_env_id
    deploy_config_group_statuses = local.deploy_status
    exported_configuration_scope = "L7AccelerationConfig"
  }
}

output "current_execution" {
  description = "Human-readable summary of what this Lab executed."
  value = {
    lab_id            = "lab-12-version-management"
    action            = "Enable Version Management, create an initial L7 configuration group version, and deploy it to Staging then Production."
    execution_mode    = "apply"
    created_resources = ["tencentcloud_teo_config_group_version.workshop_l7", "tencentcloud_teo_deploy_config_group_version.workshop_l7_staging", "tencentcloud_teo_deploy_config_group_version.workshop_l7_production"]
    resource_names = {
      version_group_id            = var.enable_version_management ? local.version_management_l7_group_id : null
      config_group_version_id     = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null)
      config_group_version_number = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_number, null)
      deploy_records              = local.deploy_record_id
      deploy_statuses             = local.deploy_status
    }
    rule_names = {
      l7_rules = ["workshop-www-https-cache"]
    }
    deploy_order    = var.version_env_id == null ? ["create version", "deploy staging", "deploy production"] : ["create version", "deploy custom environment"]
    expected_result = "Initial L7 configuration version is active in the target version-management environments."
    next_lab        = "lab-13-update-version"
  }
}
output "execution_steps" {
  description = "Ordered resource creation or modification details for this Lab."
  value = [
    {
      step      = 1
      operation = "modify"
      resource  = "tencentcloud_teo_zone.zone"
      name      = tencentcloud_teo_zone.zone.zone_name
      details = {
        work_mode               = "version_control"
        version_config_type     = "L7AccelerationConfig"
        discovered_group_id     = var.enable_version_management ? local.version_management_discovered_l7_group_id : null
        discovered_prod_env_id  = var.enable_version_management ? local.version_management_discovered_prod_env_id : null
        discovered_stage_env_id = var.enable_version_management ? local.version_management_discovered_stage_env_id : null
      }
    },
    {
      step      = 2
      operation = var.enable_version_management ? "create" : "skip"
      resource  = "tencentcloud_teo_config_group_version.workshop_l7"
      name      = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, "initial L7 version")
      details = {
        version_group_id    = var.enable_version_management ? local.version_management_l7_group_id : null
        version_id          = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_id, null)
        version_number      = try(tencentcloud_teo_config_group_version.workshop_l7[0].version_number, null)
        included_rule_names = "workshop-www-https-cache"
      }
    },
    {
      step      = 3
      operation = var.enable_version_deploy ? "deploy" : "skip"
      resource  = "tencentcloud_teo_deploy_config_group_version.workshop_l7"
      name      = "staging then production"
      details = {
        deploy_order   = var.version_env_id == null ? "staging,production" : "custom"
        deploy_records = jsonencode(local.deploy_record_id)
        deploy_env_ids = jsonencode(local.deploy_env_id)
        deploy_status  = jsonencode(local.deploy_status)
      }
    }
  ]
}

output "next_lab" {
  description = "Next Lab to run after this Lab succeeds."
  value       = "lab-13-update-version"
}

output "workshop_result" {
  description = "Final Lab result summary."
  value = {
    lab_id      = "lab-12-version-management"
    lab_success = var.enable_version_management ? (data.tencentcloud_teo_export_zone_config.l7_acceleration[0].content != "" ? "success" : "failed") : "success"
    next_lab    = "lab-13-update-version"
  }
}
