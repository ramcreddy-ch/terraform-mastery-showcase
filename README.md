# Terraform Mastery Showcase: The "One-Stop Solution" 🏗️⚙️

> **Level**: Senior / Principal / Infrastructure Architect (10+ Years Experience)

Welcome to the definitive guide to modern Infrastructure as Code. This repository is not a "getting started" guide. It is an architectural showcase for professionals who design, secure, and scale infrastructure for high-growth enterprises.

## 🗺️ The Mastery Curriculum

### [01. Foundations at Scale](./01-foundations-at-scale/)

Moving beyond local state.

- **Architectural Patterns**: Remote state sharding, S3/DynamoDB multi-region locking.
- **Backend Strategies**: Workspace-based isolation vs. folder-structured hierarchical state.
- **Initialization**: Custom `-backend-config` for dynamic environments.

### [02. Advanced Modular Design](./02-advanced-modular-design/)

Abstractions that don't leak.

- **Module Composition**: Creating building blocks using nested modules.
- **Dependency Inversion**: Using Data Sources as an interface between decoupled stacks.
- **Semantic Versioning**: Managing provider and module constraints in large teams.

### [03. The Logic Layer](./03-the-logic-layer/)

The full power of HCL.

- **Complex Functions**: Mastery of `flatten`, `zipmap`, `merge`, and `lookup`.
- **Iterative Logic**: Advanced `for_each` and `dynamic` blocks for flexible resource creation.
- **Strict Typing**: Variable `validation` blocks and granular type constraints (`map(object({...}))`).

### [04. Security and Compliance](./04-security-and-compliance/)

DevSecOps at the infrastructure level.

- **Secrets Management**: Native integration with HashiCorp Vault and Cloud secret stores.
- **Policy-as-Code**: Real-time compliance using Sentinel and OPA (Rego).
- **Audit & Drift**: Detecting and reconciling infrastructure drift in production.

### [05. Multi-Cloud Patterns](./05-multi-cloud-patterns/)

Architecture beyond a single provider.

- **Provider Aliases**: Multi-region (e.g., us-east-1 vs eu-west-1) and Multi-account orchestration.
- **Cloud-Agnostic Abstractions**: Mapping common resources across AWS, Azure, and GCP.

### [06. Terraform Internals](./06-terraform-internals/)

Understanding the engine.

- **The Graph**: Mastering the Directed Acyclic Graph (DAG) and resolving cycles.
- **Plugins/Providers**: Overview of the RPC plugin architecture and Go-based provider development.
- **External Data Sources**: Extending Terraform with non-native logic.

### [07. The CLI Power User Guide](./07-cli-guide/)

Full mastery of the `terraform` binary.

- **State Manipulation**: `state mv`, `state rm`, `import` – moving resources without destruction.
- **Debugging**: `terraform console`, `TF_LOG=TRACE`, and `force-unlock`.
- **Advanced Flow**: `graph`, `output -json`, and `providers` analysis.

### [08. Enterprise Workflow](./08-enterprise-workflow/)

Life in production.

- **DRY Code**: Implementing **Terragrunt** for large-scale DRY infrastructure.
- **Orchestration**: Self-hosted Atlantis vs. Terraform Cloud/Enterprise.
- **Migration Patterns**: Blue/Green infrastructure and zero-downtime database updates.

---

## 🛠️ Philosophy

1. **DRY (Don't Repeat Yourself)**: If you're copying blocks, you're doing it wrong.
2. **Immutability**: Infrastructure should be replaced, not repaired.
3. **Least Privilege**: Terraform roles should only have the permissions they absolutely need.
4. **State as a Secret**: State contains sensitive data; treat it like your database.

---

*Curated for the Principal DevOps Engineer by the Antigravity Team.*
