# Shared Terraform State

`shared/` stores the local Terraform state shared by the directory-based Labs.

Each Lab `versions.tf` uses the same local backend:

```hcl
backend "local" {
  path = "../../../shared/edgeone-workshop.tfstate"
}
```

Purpose:

- Allow `lab-01` through `lab-16` to run sequentially.
- Avoid creating isolated state files inside each Lab directory.
- Let later Labs recognize EdgeOne resources created by earlier Labs.
- After Lab 12 enables Version Management, prevent Lab 01 through Lab 11 from running backward and changing earlier immediate-effect configuration.

Reset:

- To restart the full workshop from Lab 01, run `./reset-shared-state.sh` from `labs/lab-01-provider-init/terraform/`.
- The script only removes local state, backup, and lock files. It does not delete cloud resources.
- If cloud resources still exist, rerunning later Labs after clearing state may hit resource-already-exists errors. Use Lab 16 for formal cleanup.
- If Lab 12 or a later Lab has already run, use Lab 16 to clean up resources and shared state before restarting from Lab 01.

Notes:

- `edgeone-workshop.tfstate` is generated at runtime.
- The formal delivery zip does not include real state files.
- Do not commit real `*.tfstate` files to Git.

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
All rights reserved.
