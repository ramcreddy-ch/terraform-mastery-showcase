# Advanced Modular Design 🧩🏗️

> **The Problem**: Bad modules are just "wrappers" that hide complexity but add no value. Great modules are "Interfaces" that provide safe defaults while exposing necessary knobs.

---

## 1. Module Composition (Atomic vs. Composite)

Don't build a single "Mega-Module" that does everything. Build **Atomic Modules** and compose them into **Service Modules**.

### 🏗️ Directory Pattern

```text
modules/
  ├── aws-vpc-atomic/      <-- Just the VPC, Subnets, IGW
  ├── aws-eks-atomic/      <-- Just the Cluster and NodeGroups
  └── enterprise-k8s-stack/ <-- COMPOSITE: orchestrates VPC + EKS + IAM
```

### 🧱 The Composition Logic

```hcl
# modules/enterprise-k8s-stack/main.tf
module "vpc" {
  source = "../aws-vpc-atomic"
  cidr   = var.vpc_cidr
}

module "eks" {
  source     = "../aws-eks-atomic"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}
```

---

## 2. Dependency Inversion (The Data Source Pattern)

In a 10+ year career, you learn that hard-linking modules (passing outputs from A to B) creates "Massive State Bloat".

**Principal Pattern**: Use **Data Sources** to decouple stacks.

### 🔌 Stack A (Networking)

Creates a VPC and tags it: `Tags = { "Environment" = "Prod", "Role" = "Core" }`.

### 🔌 Stack B (Compute)

Instead of taking `vpc_id` as a variable, Stack B **searches** for it.

```hcl
# infrastructure/compute/data.tf
data "aws_vpc" "core" {
  filter {
    name   = "tag:Environment"
    values = ["Prod"]
  }
  filter {
    name   = "tag:Role"
    values = ["Core"]
  }
}

# Now use data.aws_vpc.core.id
```

**Why?**: You can now update the Networking stack completely independently of the Compute stack.

---

## 3. Version Constraint Strategies

In enterprise environments, inconsistent provider versions result in "State Flipping" (where every developer's machine changes the state slightly).

### 🏆 The Rule of Three

1. **Modules**: Use `>=` (Minimum version) to allow flexibility for consumers.
2. **Root Projects**: Use `~>` (Pessimistic constraint) or `=` (Exact) to ensure local consistency.
3. **Provider**: Use `required_providers` in every module.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Only allows patch updates (5.x.y)
    }
  }
}
```

---

## 4. The "Registry" vs. "Local" Path

- **Development**: Use local paths (`source = "../../modules/vpc"`).
- **Production**: Use a Git URL with a **Tag** or **Commit SHA**.

```hcl
module "vpc" {
  source = "git::https://github.com/myorg/tf-modules.git//vpc?ref=v1.2.3"
}
```

**Principal Tip**: Never use `ref=master`. It's a recipe for unannounced breaking changes in production.
