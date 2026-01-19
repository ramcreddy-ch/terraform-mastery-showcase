# Security and Compliance (DevSecOps) 🔒👮

> **The Problem**: Infrastructure as Code can replicate a security misconfiguration (like an open S3 bucket) across 1,000 instances in seconds. Security must be "Shifted Left" into the code.

---

## 1. Zero-Secret Strategy (OIDC & Vault)

Stop putting AWS Access Keys or Database Passwords in `terraform.tfvars`.

### 🏆 The Principal Pattern: HashiCorp Vault Integration

Instead of hardcoding, Terraform requests a dynamic credential from Vault.

```hcl
# main.tf
data "vault_generic_secret" "db_creds" {
  path = "secret/production/db"
}

resource "aws_db_instance" "main" {
  # ...
  password = data.vault_generic_secret.db_creds.data["password"]
}
```

---

## 2. Policy-as-Code (The "Guardrail" Layer)

Ensuring compliance *before* the infrastructure is built.

### 🛡️ Open Policy Agent (OPA) / Rego

Example logic: "Block any S3 bucket that doesn't have Public Access Blocked".

```rego
# policy.rego
package terraform

deny[msg] {
  resource := input.resource_changes[_]
  resource.type == "aws_s3_bucket"
  resource.change.after.acl == "public-read"
  msg = sprintf("S3 bucket %v must not be public!", [resource.address])
}
```

**Workflow Integration**:

```bash
terraform plan -out=tfplan.json
opa exec --policy policy.rego tfplan.json
```

---

## 3. Infrastructure Drift Detection

Drift is when someone changes the Cloud Console manually, bypassing Git.

- **`terraform plan -refresh-only`**: (v1.1+) Shows where the cloud differs from state without proposing infrastructure changes.
- **DriftCTL**: An external tool (now part of Snyk) that scans your cloud account and finds resources NOT managed by Terraform at all.

---

## 4. Encryption & State Security

Since the Terraform state file contains "Plain Text" secrets (by design, to track changes), it is the **High Value Target** for attackers.

### 👮 Security Checklist

1. **Server Side Encryption (SSE)**: Mandatory for S3 backend.
2. **Access Control**: State buckets should have restricted IAM roles (only CI/CD and Admin should have access).
3. **MFA Delete**: Enable on the S3 bucket to prevent accidental or malicious state destruction.
4. **Terraform 1.6+ Encryption**: Use the new native state encryption feature to encrypt the JSON blob itself with an AWS KMS key *before* it leaves the runner.

---

## 5. Tooling for the Principal Engineer

- **Checkov**: Static analysis of TF code for over 1000 security policies.
- **TFSec**: High-performance linter specializing in security misconfigs.
- **Infracost**: Not strictly security, but "Financial Compliance" – see how much a plan will cost before you apply it.
