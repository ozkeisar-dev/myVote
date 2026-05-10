# Runbook — GitHub repo controls (`ozkeisar-dev/myVote`)

This runbook is the click-path for the parts of [MYV-19](https://multica.ai) that can
only be configured in the GitHub UI: branch protection, tag protection,
environments, and required status checks.

Do this once, after this PR is merged. Re-do the relevant section any time
something needs to change (e.g. flipping a CI check from named to required
when [MYV-20](https://multica.ai) ships).

> **Repo:** `ozkeisar-dev/myVote` is the source of truth. The personal
> `ozkeisar/myVote` is intentionally left untouched and is **not** the working
> repo.

---

## 1. Branch protection — `main`

**Path:** Repo → Settings → Branches → Branch protection rules → **Add rule**.

Fill in:

| Field                                                              | Value                                       | Decided in                   |
| ------------------------------------------------------------------ | ------------------------------------------- | ---------------------------- |
| Branch name pattern                                                | `main`                                      | —                            |
| Require a pull request before merging                              | ✅                                          | description                  |
| └ Require approvals                                                | ✅, **1**                                   | description                  |
| └ Dismiss stale pull request approvals when new commits are pushed | ✅                                          | recommended                  |
| └ Require review from Code Owners                                  | ✅                                          | derives from CODEOWNERS      |
| Require status checks to pass before merging                       | ✅                                          | description                  |
| └ Require branches to be up to date before merging                 | ✅                                          | recommended                  |
| └ Status checks                                                    | **leave empty for now** — see "Day 2" below | [MYV-20](https://multica.ai) |
| Require conversation resolution before merging                     | ✅                                          | recommended                  |
| Require signed commits                                             | ⬜ off                                      | Q3                           |
| Require linear history                                             | ⬜ off                                      | Q4                           |
| Require deployments to succeed before merging                      | ⬜ off                                      | not yet                      |
| Lock branch                                                        | ⬜ off                                      | —                            |
| Do not allow bypassing the above settings                          | ✅ on                                       | Q5                           |
| Restrict who can push to matching branches                         | ⬜ off                                      | not needed today             |
| Allow force pushes                                                 | ⬜ off                                      | description                  |
| Allow deletions                                                    | ⬜ off                                      | description                  |

Click **Create** / **Save changes**.

### Day 2 — flip CI checks from named to required

Run as part of [MYV-20](https://multica.ai)'s acceptance, not now:

1. Settings → Branches → edit the `main` rule.
2. Under **Status checks**, search for and add:
   - `typecheck`
   - `lint`
   - `test`
3. Save.

Until [MYV-20](https://multica.ai) ships, branch protection without required checks is a
**soft gate** — PRs can still merge with no CI. That's intentional: marking a
non-existent check as required deadlocks every PR.

### Break-glass — when an admin (you) genuinely needs to bypass

Because "Do not allow bypassing" is on:

1. Settings → Branches → edit the `main` rule.
2. **Untick** "Do not allow bypassing".
3. Do the thing (force-push, hot-fix merge, whatever).
4. **Re-tick** the toggle and save.

The toggle change is recorded in the repo's audit log (Settings → Audit log).
That is intentional — every bypass should leave a trail.

---

## 2. Tag protection — `v*`

Production deploys are triggered by tags matching `v*` (per [MYV-25](https://multica.ai)). Protect them so a typo doesn't ship a release.

**Path:** Repo → Settings → Tags → **New rule**.

| Field            | Value |
| ---------------- | ----- |
| Tag name pattern | `v*`  |

Click **Add rule**. Only collaborators with **Maintain** or **Admin** roles can
create / delete protected tags. Today that's just `@ozkeisar`.

---

## 3. Environments

**Path:** Repo → Settings → Environments → **New environment**.

Create three environments. Each gets its own deploy token and runtime config
(see `docs/secrets.md`).

### 3a. `preview`

| Setting                      | Value                                                                               |
| ---------------------------- | ----------------------------------------------------------------------------------- |
| Name                         | `preview`                                                                           |
| Required reviewers           | ⬜ none                                                                             |
| Wait timer                   | `0 minutes`                                                                         |
| Deployment branches and tags | **All branches** (preview deploys per PR)                                           |
| Environment secrets          | none yet — populated by [MYV-22](https://multica.ai) / [MYV-25](https://multica.ai) |

### 3b. `staging`

| Setting                      | Value                                                                               |
| ---------------------------- | ----------------------------------------------------------------------------------- |
| Name                         | `staging`                                                                           |
| Required reviewers           | ⬜ none                                                                             |
| Wait timer                   | `0 minutes`                                                                         |
| Deployment branches and tags | **Selected branches and tags** → add rule for `main`                                |
| Environment secrets          | none yet — populated by [MYV-22](https://multica.ai) / [MYV-25](https://multica.ai) |

### 3c. `production`

| Setting                      | Value                                                                               |
| ---------------------------- | ----------------------------------------------------------------------------------- |
| Name                         | `production`                                                                        |
| Required reviewers           | ✅ **`@ozkeisar`** (Q2 — sole reviewer; the bot does not gate its own deploys)      |
| Wait timer                   | `0 minutes` (we may add a 5-minute timer later — flag if you want it now)           |
| Deployment branches and tags | **Selected branches and tags** → add tag rule for `v*`                              |
| Environment secrets          | none yet — populated by [MYV-22](https://multica.ai) / [MYV-25](https://multica.ai) |

---

## 4. Required collaborators

Today the only GitHub collaborator with **write** access (and therefore the
only handle that CODEOWNERS can auto-request review from) is:

- `@ozkeisar` — owner / admin
- `@amitayks` — agent collaborator (write access)

If you add another agent or human, also add them as a collaborator
(Settings → Collaborators) before referencing them in `.github/CODEOWNERS` —
otherwise the rule is silent.

---

## 5. After running this runbook

Reply on [MYV-19](https://multica.ai) with:

- ✅ branch protection on `main`
- ✅ tag protection on `v*`
- ✅ environments: `preview`, `staging`, `production` (with prod reviewer)
- ⏸ required CI checks (deferred to [MYV-20](https://multica.ai))

Tech Lead closes the ticket.
