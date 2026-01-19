# Foundations at Scale 🏗️🌐

> **The Problem**: Shared state in a multi-region, multi-account enterprise environment is the #1 source of "Automation Deadlocks" and "State Corruption".

---

## 1. Multi-Region State Management (High Availability)

For a Principal Engineer, "Local State" is a non-starter. But even a simple S3 bucket in one region is a Single Point of Failure (SPOF).

### 🏆 The "Gold Standard" Backend Configuration

This configuration ensures that:

1. State is encrypted at rest (AES-256).
2. State is versioned (Instant recovery from accidental logic errors).
3. Concurrent runs are locked via DynamoDB (Prevents state corruption).

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod-001"
    key            = "foundation/networking/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}
```

---

## 2. Dynamic Backend Injection (Context-Aware Init)

In a 10+ year career, you learn that hardcoding bucket names in `backend.tf` is a maintenance nightmare. Instead, use **Partial Configuration**.

### 🛠️ The Implementation

1. Leave the `backend` block empty in your code.
2. Maintain separate `.hcl` files for `dev`, `staging`, and `prod`.

```hcl
# backend-configs/prod-us-east.hcl
bucket = "my-enterprise-state-prod"
region = "us-east-1"
key    = "core/vpc/terraform.tfstate"
```

**CLI Command**:

```bash
terraform init -backend-config=backend-configs/prod-us-east.hcl
```

---

## 3. Workspaces vs. Hierarchical Folders

### ⚔️ The Great Debate

- **Workspaces**: Great for "Review Environments" (Ephemeral).
- **Folders**: Better for "Production Environments" (Permanent).

**Principal Recommendation**: For Production, use **Folders**.
Folders allow you to:

1. Use different provider versions per environment.
2. Maintain separate `access_control` on the state files.
3. Visually audit the difference in environmental complexity.

```text
infrastructure/
  ├── prod/
  │   ├── vpc/             <-- State 1
  │   └── eks/             <-- State 2 (depends on vpc)
  └── staging/
      ├── vpc/
      └── eks/
```

---

## 4. State Disaster Recovery (Principal Protocol)

When a state file is corrupted or a run is interrupted:

1. **Rollback**: Identify the previous version of the `.tfstate` file in S3.
2. **Download**: `terraform state pull > corrupt.tfstate`.
3. **Restore**:

   ```bash
   # Using AWS CLI to restore a specific version
   aws s3api get-object --bucket my-bucket --key my-key --version-id some-id terraform.tfstate
   # Then push back to the backend
   terraform state push terraform.tfstate
   ```

---

## 🚀 Advanced Init: Automation

In a high-scale CI/CD environment, always use:

- **`-get-plugins=false`**: (If using pre-baked images) Speeds up runs.
- **`-input=false`**: Ensures the job fails if a required variable is missing, rather than hanging for input.
