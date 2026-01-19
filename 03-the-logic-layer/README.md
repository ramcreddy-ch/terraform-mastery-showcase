# The Logic Layer: Advanced HCL 🧠⚡

> **The Problem**: Infrastructure is rarely static. You need to handle lists of varying sizes, optional parameters, and complex data relationships without repeating code.

---

## 1. Mastery of `for_each` and `dynamic` blocks

Move from static resource blocks to **Data-Driven Infrastructure**.

### 🧱 The `dynamic` Block Pattern

Useful for resources with nested configuration blocks (like Security Group rules or S3 Lifecycles).

```hcl
variable "ingress_rules" {
  type = list(object({
    port        = number
    description = string
  }))
}

resource "aws_security_group" "standard" {
  name = "app-sg"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      description = ingress.value.description
      cidr_blocks = ["10.0.0.0/8"]
    }
  }
}
```

---

## 2. Advanced Collection Manipulation

### `flatten`: The CSV/JSON Normalizer

When you have a nested map of data (e.g., Accounts -> Subnets) and need to create a flat list of resources.

```hcl
locals {
  network_config = {
    "us-east" = ["sub-1", "sub-2"]
    "us-west" = ["sub-3"]
  }

  # Result: ["us-east:sub-1", "us-east:sub-2", "us-west:sub-3"]
  flat_subnets = flatten([
    for region, subs in local.network_config : [
      for s in subs : {
        region = region
        name   = s
      }
    ]
  ])
}
```

---

## 3. Strict Variable Validation

A Principal Engineer doesn't just check if a variable is a "string". They validate its **Business Logic**.

```hcl
variable "environment" {
  type        = string
  description = "Target environment"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }

  validation {
    condition     = can(regex("^v[0-9]+", var.environment) == false)
    error_message = "Environment cannot start with 'v' to avoid confusion with version tags."
  }
}
```

---

## 4. The "Optional" & "Nullable" Strategy

(Terraform 1.3+) Use defaults for complex objects.

```hcl
variable "cluster_config" {
  type = object({
    name      = string
    instances = optional(number, 3)
    type      = optional(string, "t3.large")
  })
}
```

If the user only provides `name`, Terraform automatically fills in the 3 nodes and type.

---

## 🚀 Key Functions to Memorize

1. **`zipmap(keys, values)`**: Create a map from two lists (e.g., IDs and Names).
2. **`lookup(map, key, default)`**: Safe access to a map with a fallback.
3. **`try(func1, func2, value)`**: Try multiple paths (useful for checking if a deep attribute exists in a data structure).
4. **`templatefile(path, vars)`**: Load external scripts (like UserData) and inject variables safely.
