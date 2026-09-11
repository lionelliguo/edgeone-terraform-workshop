# Shared Terraform State

`shared/` 用于保存目录式 Lab 共用的 Terraform 本地 state。

每个 Lab 的 `versions.tf` 都配置了相同的 local backend：

```hcl
backend "local" {
  path = "../../../shared/edgeone-workshop.tfstate"
}
```

作用：

- 让 `lab-01` 到 `lab-16` 可以按顺序连续执行。
- 避免每个 Lab 目录生成彼此独立的 state。
- 让后续 Lab 能识别前面 Lab 已经创建的 EdgeOne 资源。
- 从 Lab 12 启用 Version Management 后，阻止 Lab 01 到 Lab 11 倒退执行，避免修改早期即时生效配置。

重置：

- 如果需要从 Lab 01 重新开始整个 workshop，可以在 `labs/lab-01-provider-init/terraform/` 下执行 `./reset-shared-state.sh`。
- 该脚本只删除本地 state、backup 和 lock 文件，不会删除云上资源。
- 如果云上资源仍然存在，清空 state 后重新执行后续 Lab 可能遇到资源已存在的错误；正式清理请使用 Lab 16。
- 如果已经执行到 Lab 12 或之后，需要先执行 Lab 16 清理资源和共享 state，再从 Lab 01 重新开始。

注意：

- `edgeone-workshop.tfstate` 是运行后自动生成的运行态文件。
- 正式交付 zip 不包含真实 state 文件。
- 不要把真实 `*.tfstate` 文件提交到 Git。

---

© 2026 Lionel Guo · lionelliguo@gmail.com  
保留所有权利。
