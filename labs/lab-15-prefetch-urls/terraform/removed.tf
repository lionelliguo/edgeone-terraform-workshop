# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
# Lab 15 manages the Purge and Prefetch task resources directly.

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
