# Secrets convention

This document is the source of truth for **where every secret lives**, **what it
is named**, and **who provisions it**. If a secret is not listed here, it does
not exist; if you need a new one, add it here in the same PR that introduces it.

## TL;DR — three tiers

| Tier | Where                               | What goes here                                                                             | Who reads it                                                                |
| ---- | ----------------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------- |
| 1    | GitHub Actions secrets (org / repo) | Build-time only — CI needs it to build, push images, deploy, or upload artefacts           | GitHub Actions workflows                                                    |
| 2    | Coolify env vars                    | Runtime config + non-KMS API keys (third-party services without crypto-grade requirements) | The running app / worker / edge worker                                      |
| 3    | Vault                               | KMS-grade — anything used to sign, MAC, or encrypt user data                               | App at runtime via Vault agent / sidecar (see [MYV-29](https://multica.ai)) |

> **Why three tiers, not one?** GHA secrets are convenient but readable by any
> workflow run; Coolify env is fine for runtime config but not for crypto keys
> that audit a vote; Vault gives us audit trails, rotation, and access policies.
> Putting a phone HMAC key in GHA is a compliance bug, not a convenience win.

## Naming convention

- **Tier 1 (GHA):** `UPPER_SNAKE_CASE`, prefix-by-provider for clarity
  (`HETZNER_API_TOKEN`, `CLOUDFLARE_API_TOKEN`). Per-environment build-time
  secrets get the env in the name (`COOLIFY_PRODUCTION_DEPLOY_TOKEN`).
- **Tier 2 (Coolify):** `UPPER_SNAKE_CASE`. Provider prefix when there are
  several (`TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`). App-config names match
  the framework convention (`DATABASE_URL`, `REDIS_URL`, `NODE_ENV`).
- **Tier 3 (Vault):** path-style, lower-kebab. `secret/data/myvote/<env>/<key>`
  — e.g. `secret/data/myvote/production/phone-hmac-key`. Finalised in
  [MYV-29](https://multica.ai).

## Hard rules

1. **No plaintext secrets in the repo, ever.** Including `.env.example` files —
   those carry only KEY names with empty values or obvious-fake placeholders.
2. **No secret values in PR descriptions, issue comments, commit messages, or
   chat threads.** Paste them directly into the destination tier's UI.
3. **No secret values in Multica comments either.** Multica is a chat
   surface; treat it like Slack.
4. **One token per environment** for anything that grants deploy or write
   access (Coolify deploy tokens, etc.). A staging breach should never burn
   production.
5. **Rotation cadence:** "on suspected leak" today, formal cadence deferred to
   a follow-up. Any token that was visible in a screenshot, log, terminal
   recording, or third-party tool is suspected leaked.
6. **Adding a new secret = updating this file** in the same PR. If you can't
   list its tier, name, owner, and status here, you don't know enough to add
   it yet.

## Where to add a new secret — flow

```
Is the value used to sign / MAC / encrypt user data?
├─ Yes → Tier 3 (Vault). Coordinate with [MYV-29].
└─ No
   │
   Is it needed at BUILD time (CI builds the image, deploys, pushes to ghcr.io)?
   ├─ Yes → Tier 1 (GHA secret).
   └─ No
      │
      It's RUNTIME config or a third-party API key
      → Tier 2 (Coolify env), one entry per environment.
```

---

## Tier 1 — GitHub Actions secrets

Stored as **repository secrets** on `ozkeisar-dev/myVote` (Settings → Secrets
and variables → Actions). Org-level secrets are not used today (no GitHub Org).

Status legend: `✅ ready` · `⏸ blocked on <issue>` · `🟡 partial`

| Name                              | Purpose                                                                               | Status                                                          |
| --------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `GHCR_PUSH_TOKEN`                 | Push container images to ghcr.io from CI                                              | ⏸ blocked on [MYV-25](https://multica.ai) (CI/CD wiring)        |
| `SENTRY_AUTH_TOKEN`               | Upload source maps + tag releases at build time                                       | ⏸ blocked on [MYV-31](https://multica.ai) (Sentry account)      |
| `COOLIFY_PREVIEW_DEPLOY_TOKEN`    | Trigger preview deploys from CI on PR events                                          | ⏸ blocked on [MYV-22](https://multica.ai) (Coolify install)     |
| `COOLIFY_STAGING_DEPLOY_TOKEN`    | Trigger staging deploys from CI on `main` merge                                       | ⏸ blocked on [MYV-22](https://multica.ai)                       |
| `COOLIFY_PRODUCTION_DEPLOY_TOKEN` | Trigger prod deploys from CI on `v*` tag (gated by `production` env approval)         | ⏸ blocked on [MYV-22](https://multica.ai)                       |
| `HETZNER_API_TOKEN`               | Provision Hetzner Cloud resources (project-scoped, R/W)                               | ⏸ blocked on [MYV-16](https://multica.ai)                       |
| `CLOUDFLARE_API_TOKEN`            | Manage DNS, Pages, Workers, R2                                                        | ⏸ blocked on [MYV-16](https://multica.ai)                       |
| `CLOUDFLARE_ACCOUNT_ID`           | Cloudflare account identifier (not strictly secret, stored as secret for convenience) | ⏸ blocked on [MYV-16](https://multica.ai)                       |
| `CLOUDFLARE_ZONE_ID`              | Zone identifier for the registered domain                                             | ⏸ blocked on [MYV-17](https://multica.ai) (domain registration) |
| `NEON_API_KEY`                    | Manage Neon Postgres branches / connection strings                                    | ⏸ blocked on [MYV-23](https://multica.ai) (Neon project)        |

> **Note on `GITHUB_TOKEN`:** GitHub injects this into every workflow run
> automatically — it is not listed above and does not need to be created.

## Tier 2 — Coolify env vars

Stored per environment in Coolify (`preview`, `staging`, `production`). Set
once per env; the Coolify deploy targets read these at container start.

| Name                       | Purpose                                                                                                      | preview                        | staging                        | production                     |
| -------------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------ | ------------------------------ | ------------------------------ |
| `NODE_ENV`                 | Standard Node env flag                                                                                       | `production`                   | `production`                   | `production`                   |
| `APP_ENV`                  | App-level env name (we use `APP_ENV` to distinguish staging from prod, since both are `NODE_ENV=production`) | `preview`                      | `staging`                      | `production`                   |
| `DATABASE_URL`             | Postgres connection string (Neon branch per env)                                                             | ⏸ [MYV-23](https://multica.ai) | ⏸ [MYV-23](https://multica.ai) | ⏸ [MYV-23](https://multica.ai) |
| `REDIS_URL`                | Redis / queue backing store                                                                                  | ⏸ [MYV-22](https://multica.ai) | ⏸ [MYV-22](https://multica.ai) | ⏸ [MYV-22](https://multica.ai) |
| `TWILIO_ACCOUNT_SID`       | Twilio account ID for OTP SMS                                                                                | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) |
| `TWILIO_AUTH_TOKEN`        | Twilio auth token                                                                                            | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) |
| `TWILIO_FROM_NUMBER`       | Sender number (or alphanumeric ID)                                                                           | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) |
| `SIGHTENGINE_USER`         | Sightengine API user                                                                                         | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) |
| `SIGHTENGINE_SECRET`       | Sightengine API secret                                                                                       | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) |
| `OPENAI_API_KEY`           | OpenAI API key                                                                                               | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) | ⏸ [MYV-27](https://multica.ai) |
| `SENTRY_DSN`               | Sentry runtime DSN (per project)                                                                             | ⏸ [MYV-32](https://multica.ai) | ⏸ [MYV-32](https://multica.ai) | ⏸ [MYV-32](https://multica.ai) |
| `BETTERSTACK_INGEST_TOKEN` | Better Stack log shipping                                                                                    | ⏸ [MYV-33](https://multica.ai) | ⏸ [MYV-33](https://multica.ai) | ⏸ [MYV-33](https://multica.ai) |
| `R2_ACCESS_KEY_ID`         | R2 / S3-compatible access key (uploads)                                                                      | ⏸ [MYV-30](https://multica.ai) | ⏸ [MYV-30](https://multica.ai) | ⏸ [MYV-30](https://multica.ai) |
| `R2_SECRET_ACCESS_KEY`     | R2 / S3-compatible secret                                                                                    | ⏸ [MYV-30](https://multica.ai) | ⏸ [MYV-30](https://multica.ai) | ⏸ [MYV-30](https://multica.ai) |
| `R2_BUCKET`                | R2 bucket name                                                                                               | ⏸ [MYV-30](https://multica.ai) | ⏸ [MYV-30](https://multica.ai) | ⏸ [MYV-30](https://multica.ai) |

`preview` env may share non-sensitive Tier 2 values with `staging` to reduce
operational overhead — e.g. `TWILIO_FROM_NUMBER` can be the same. Anything that
counts against a paid quota or sends real SMS / API calls to a billed provider
should be paused or stubbed in `preview`. Confirm per-provider in [MYV-27](https://multica.ai).

## Tier 3 — Vault

KMS-grade keys. Vault provisioning + injection contract is owned by [MYV-29](https://multica.ai);
this section locks the names so other tickets can refer to them.

| Path                                           | Purpose                                                                       | Status                                    |
| ---------------------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------- |
| `secret/data/myvote/<env>/phone-hmac-key`      | HMAC key for hashing phone numbers (privacy + de-duplication)                 | ⏸ blocked on [MYV-29](https://multica.ai) |
| `secret/data/myvote/<env>/vote-audit-hmac-key` | HMAC key signing vote-audit records (per [MYV-14](https://multica.ai) §audit) | ⏸ blocked on [MYV-29](https://multica.ai) |

Vault runs on the dedicated Hetzner VM from [MYV-28](https://multica.ai). Apps fetch keys
via the agent contract finalised in [MYV-29](https://multica.ai); never bake them into
container images, never log them, never mirror them into Coolify env.

## Updating this document

- Add a new row when a new secret name is reserved, even if its value is still
  blocked. Mark `⏸ blocked on MYV-NN` so the dependency is visible.
- Flip status to `✅ ready` only when the secret has actually been pasted into
  its destination (verified by the owner of the dependency ticket).
- Removing a secret? Open a follow-up ticket; rotation + revocation order
  matters and is easy to get wrong.
