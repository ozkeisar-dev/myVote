# myVote

A voting platform for Israel — user polls, national election tracking, and results analysis.

## Stack

| Layer      | Technology                                           |
| ---------- | ---------------------------------------------------- |
| Monorepo   | pnpm workspaces                                      |
| Language   | TypeScript (strict)                                  |
| Linting    | ESLint 8 + @typescript-eslint + eslint-plugin-import |
| Formatting | Prettier 3                                           |
| Node       | 22.x (LTS)                                           |

## Apps

| Package            | Description           |
| ------------------ | --------------------- |
| `apps/server`      | Backend API server    |
| `apps/worker`      | Background job worker |
| `apps/worker-edge` | Edge runtime worker   |
| `apps/web`         | Mobile-first web app  |
| `apps/admin`       | Admin dashboard       |

## Packages

| Package                  | Description                       |
| ------------------------ | --------------------------------- |
| `packages/shared`        | Shared types and utilities        |
| `packages/db`            | Database client and schema        |
| `packages/i18n`          | Hebrew/English localisation       |
| `packages/algo`          | Election results comparison logic |
| `packages/tsconfig`      | Shared TypeScript configs         |
| `packages/eslint-config` | Shared ESLint config              |

## Install

```bash
# Requires Node 22+ and pnpm 9+
corepack enable
pnpm install
```

## Tasks

| Command             | Description                    |
| ------------------- | ------------------------------ |
| `pnpm typecheck`    | Type-check all packages        |
| `pnpm lint`         | Lint all packages              |
| `pnpm format`       | Format all files with Prettier |
| `pnpm format:check` | Check formatting (CI)          |

## Governance & secrets

- [`docs/secrets.md`](docs/secrets.md) — three-tier secrets convention (GHA / Coolify / Vault), naming, and which slot each secret lives in.
- [`docs/runbooks/github-repo-controls.md`](docs/runbooks/github-repo-controls.md) — branch protection, environments, and tag protection setup.
- [`.github/CODEOWNERS`](.github/CODEOWNERS) — review routing per `apps/*` and `packages/*`.
- [`.github/pull_request_template.md`](.github/pull_request_template.md) — PR checklist (tests, screenshots, breaking-change flag, migration safety).
