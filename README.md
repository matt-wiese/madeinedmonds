# Made in Edmonds

Handmade wooden pet urns from Edmonds, Washington, and the production stack behind the shop, built in public as a hands-on full-stack and SRE project.

[![CI](https://github.com/matt-wiese/madeinedmonds/actions/workflows/ci.yml/badge.svg)](https://github.com/matt-wiese/madeinedmonds/actions/workflows/ci.yml)

> **Status:** GitHub setup now compeleted (December 2026). Nothing is for sale yet.

## What's in this repository

| Path | What it is |
|---|---|
| `infra/github/` | Terraform that manages this repository's own settings: branch rules, deployment environments, Actions permissions, security features |
| `docs/adr/` | Architecture decision records: what was decided, and why |
| `.github/` | CI workflow, Dependabot, pull request template, code owners |

Coming next: `infra/aws/` (accounts, networking, hosting), `web/` (React storefront) and `api/` (Node API).

## Architecture (planned)

```
Customer ──▶ CloudFront ──▶ S3: React + TypeScript storefront
                 │
                 └── /api ──▶ Load balancer ──▶ ECS Fargate: Node + TypeScript API ──▶ RDS PostgreSQL
                                                    │
                                                    ├──▶ Stripe Checkout (hosted payment page)
                                                    │      └── webhook back to the API when paid
                                                    └──▶ SES (order emails)
```

- Separate AWS accounts for `staging` and `production`, managed with AWS Organizations.
- Everything is defined in Terraform and deployed by GitHub Actions, which gets short-lived AWS credentials through OIDC. No AWS keys are stored anywhere.
- Monitoring with CloudWatch: dashboards, alarms, and a scheduled canary that walks through checkout.

## How a change gets made

1. Create a branch from `main` and make the change.
2. Open a pull request. CI must pass (the `ci-passed` check).
3. Squash-merge. `main` accepts no direct pushes, force pushes or deletion.
4. Deployments to `production` wait for manual approval.

## Roadmap

- [ ] **December: foundations.** GitHub, AWS accounts, Terraform state, DNS, a "coming soon" page
- [ ] **January: the app.** Storefront and API skeleton; staging infrastructure
- [ ] **February: orders end to end.** Checkout, webhooks, order emails in staging; production stood up
- [ ] **March: reliability.** SLOs, alerting, canaries, runbooks, restore drills, game days
- [ ] **April: launch**

## Decisions

- [ADR 0001: Record architecture decisions](docs/adr/0001-record-architecture-decisions.md)
- [ADR 0002: Public monorepo on GitHub Free](docs/adr/0002-public-monorepo-on-github-free.md)
- [ADR 0003: Application stack](docs/adr/0003-application-stack.md)

## Security

See [SECURITY.md](SECURITY.md) to report a vulnerability.
