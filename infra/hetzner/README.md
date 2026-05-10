# Hetzner VM provisioning (MYV-21)

Terraform skeleton for the three Hetzner Cloud VMs the M1 deploy path needs:

| Role               | Type (default) | RAM   | vCPU | Purpose                          |
| ------------------ | -------------- | ----- | ---- | -------------------------------- |
| `myvote-coolify`   | `cpx21`        | 4 GB  | 3    | Coolify orchestrator (MYV-22)    |
| `myvote-app-staging` | `cpx21`      | 4 GB  | 3    | Staging app host                 |
| `myvote-app-prod`  | `cpx31`        | 8 GB  | 4    | Production app host              |

Defaults are starting points. Override in CI or via `tfvars` once we agree on sizing.

## What this does NOT do yet

- **Apply.** The `hetzner-plan.yml` workflow runs `terraform plan` only. Apply is a separate workflow + manual approval, gated behind sign-off in MYV-21.
- **State backend.** Local state for now. Real backend (Terraform Cloud free tier or Cloudflare R2 + workspace lock) is a separate decision.
- **SSH key creation.** The `ssh_key_name` variable refers to a key that must already exist in the Hetzner project. Creating it is a manual step (paste public key into Hetzner UI → Security → SSH keys).
- **Private network / firewalls.** Out of scope for the skeleton; layered on once roles are stable.

## Decisions still needed before apply

1. **VM types** — confirm `cpx21 / cpx21 / cpx31` is acceptable. Cost estimate at default location `fsn1`:
   - `cpx21` ≈ €5.83 / mo each → 2 × €5.83 = €11.66
   - `cpx31` ≈ €11.66 / mo
   - **Total ≈ €23.32 / mo** (excludes traffic).
2. **Region** — defaulting to `fsn1` (Falkenstein). If you want Nuremberg use `nbg1`.
3. **SSH key name** — what name should the project-level SSH key be registered under? Default suggestion: `myvote-ops`.
4. **State backend** — TFC free tier (zero infra) or R2 (we own it but needs locking via DynamoDB-equivalent — not ideal for a small team)?

## Local usage

```sh
cd infra/hetzner
export HCLOUD_TOKEN=...   # NEVER commit
terraform init
terraform plan -var ssh_key_name=myvote-ops
```

## CI usage

The `hetzner-plan.yml` workflow consumes `secrets.HETZNER_API_TOKEN` and runs `terraform plan` on PRs that touch `infra/hetzner/**`. The plan output is posted as a PR comment.
