# Multi-Cloud & Multi-Account Patterns ☁️☁️

> **The Problem**: Organizations rarely live in a single region or a single cloud. You need to orchestrate traffic and data across boundaries without duplicating your entire codebase.

---

## 1. Provider Aliases (The Orchestrator Pattern)

Manage multiple regions or multiple AWS accounts in a single project.

### 🧱 Multi-Region Peering

```hcl
# providers.tf
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# main.tf
resource "aws_vpc" "east" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "west" {
  provider   = aws.west # Explicitly use the west alias
  cidr_block = "10.2.0.0/16"
}
```

---

## 2. Cross-Account Architecture

Useful for "Hub and Spoke" networking or "Central Logging" accounts.

```hcl
provider "aws" {
  alias = "security_account"
  assume_role {
    role_arn = "arn:aws:iam::111122223333:role/TerraformRole"
  }
}

resource "aws_cloudwatch_log_destination" "central" {
  provider = aws.security_account
  name     = "central-logging"
  # ...
}
```

---

## 3. "Cloud-Agnostic" vs "Cloud-Native"

### ⚔️ The Principal Reality Check

"True" Cloud Agnosticism (one code for AWS and Azure) is a myth because resource attributes (e.g., `ami` vs `image_id`) are fundamentally different.

**The Solution**: Use **Standardized Variable Interfaces**.

Maintain different root modules for each cloud, but ensure your **Inputs** and **Outputs** follow the same naming convention. This allows your CI/CD and Higher-level Orchestration (like K8s or ArgoCD) to treat the clouds as identical entities.

---

## 4. Multi-Cloud Inventory

When dealing with hybrid clouds:

1. **Terraform Data Sources**: Read state from Azure in an AWS-centric project.
2. **External Data Sources**: Use a Python script to fetch metadata from a 3rd party IPAM (IP Address Management) system to ensure CIDR blocks don't overlap across AWS and GCP.

---

## 🚀 Key Takeaway

For a 10+ year veteran, the focus isn't just on "creating a VM". It's on **Traffic Engineering**. Focus on `Transit Gateways`, `Peering Connects`, and `Private Links` that bridge the accounts you manage.
