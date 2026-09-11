# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
# Prevents accidental backward plans from directly destroying later-Lab resources.
# Sequence guards still reject out-of-order execution; these blocks only forget matching objects from Terraform state and never delete cloud resources.

removed {
  from = tencentcloud_teo_prefetch_task_operation.www_home

  lifecycle {
    destroy = false
  }
}

removed {
  from = time_sleep.before_version_management_enable

  lifecycle {
    destroy = false
  }
}

removed {
  from = time_sleep.after_version_management_enable

  lifecycle {
    destroy = false
  }
}

removed {
  from = time_sleep.before_update_version

  lifecycle {
    destroy = false
  }
}

removed {
  from = time_sleep.after_update_version_ready

  lifecycle {
    destroy = false
  }
}
