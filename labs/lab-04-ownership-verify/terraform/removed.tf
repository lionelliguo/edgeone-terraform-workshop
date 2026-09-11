# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
# Prevents accidental backward plans from directly destroying later-Lab resources.
# Sequence guards still reject out-of-order execution; these blocks only forget matching objects from Terraform state and never delete cloud resources.

removed {
  from = tencentcloud_teo_acceleration_domain.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_dnspod_record.www_cname

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_certificate_config.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_l7_acc_rule_v2.www_https_and_cache

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_security_policy_config.zone_default

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_web_security_template.workshop

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_bind_security_template.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_purge_task.www_home

  lifecycle {
    destroy = false
  }
}

removed {
  from = tencentcloud_teo_prefetch_task_operation.www_home

  lifecycle {
    destroy = false
  }
}
