# The CLI Power User Guide ⌨️🚀

> **Context**: For a Principal Engineer, the CLI isn't just for `plan` and `apply`. It's a scalpel for state surgery and a microscope for dependency analysis.

---

## 🏗️ 1. The Core Workflow

### `terraform init`

Beyond the basics.

- **`-reconfigure`**: Ignore existing configuration and start fresh (useful when switching backends).
- **`-migrate-state`**: Move state from local to remote (or S3 to GCS).
- **`-backend-config=path/to/prod.hcl`**: inject secret backend config at runtime.

### `terraform plan`

Predicting the future.

- **`-out=tfplan`**: Save the plan to a file. **MANDATORY** for CI/CD to prevent race conditions.
- **`-target=resource.name`**: (Use with caution) Narrow the scope of a plan. Useful for fixing a specific broken resource without triggering a graph-wide refresh.
- **`-replace="module.vpc.aws_instance.web[0]"`**: (Terraform 1.0+) Force a resource to be recreated even if no changes are detected. Replaces the legacy `taint`.

### `terraform apply`

Execution with precision.

- **`terraform apply tfplan`**: Apply the *exact* saved plan. No confirmation required (ideal for automation).
- **`-parallelism=N`**: Increase/decrease concurrent operations (default 10). useful for speeding up massive deployments or slowing down to avoid API throttling.

---

## 💾 2. State Surgery (`terraform state`)

State is the "Source of Truth" according to Terraform. When the truth drifts, you use these commands.

- **`terraform state list`**: List every resource in the current state (including modules).
- **`terraform state show <address>`**: View the detailed attributes of a specific resource in state.
- **`terraform state mv <source> <destination>`**:
  - **Usecase**: Refactoring code. If you move a resource into a module, Terraform will try to delete and recreate it. `state mv` allows you to "move" it in the state file so Terraform understands it's the same physical resource.
- **`terraform state rm <address>`**: Stop managing a resource without deleting it from the cloud.
- **`terraform state pull / push`**: Manually download or upload the state JSON (dangerous, but necessary for manual corruption fixes).

---

## 🛠️ 3. Troubleshooting & Debugging

- **`terraform console`**: Interactive sandbox to test HCL functions (`lookup`, `merge`, `flatten`) against your real variables and state.
- **`terraform force-unlock <LOCK_ID>`**: Recover from a crashed CI job that left a DynamoDB/Local lock active.
- **`TF_LOG=TRACE terraform plan`**: Enable maximum verbosity. Essential for debugging provider internal errors or API request/response cycles.
- **`terraform graph | dot -Tpng > graph.png`**: Generate a visual representation of your infrastructure dependencies.

---

## 📥 4. Reconciliation

- **`terraform import <address> <cloud_id>`**:
  - **Scenario**: You created a database manually in the console. Now you want it managed by Terraform. `import` brings the *attributes* into the state. You still need to write the `.tf` code to match.
- **`terraform refresh`**: (Merged into `plan` by default) Manually trigger the "refresh" phase to update the state with reality from the cloud provider.

---

## 🏢 5. Provider & Version Management

- **`terraform providers`**: Shows a tree of all providers required by your modules. Essential for tracking down "Ghost" provider requirements.
- **`terraform version`**: Shows CLI and Provider versions.
- **`terraform login / logout`**: Manage credentials for Terraform Cloud / Enterprise.

---

## 💡 Principal Tip: The "Alias" Pattern

When managing 50 AWS accounts, don't use 50 directories. Use **Provider Aliases** and the CLI:

```bash
# Apply to a specific region/account via environment
terraform plan -var="region=us-west-2" -target=module.compute.aws_instance.web
```
