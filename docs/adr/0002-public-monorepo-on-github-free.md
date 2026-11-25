# 2. Public monorepo on GitHub Free

- **Status:** Accepted
- **Date:** 2026-11-24

## Context

The project needs source control, CI/CD, branch protection, and a manual approval step before production deploys. It's also meant to show full-stack and SRE skills to future employers.

On GitHub Free, private repositories don't get protected branches or deployment protection rules (manual approvals). Public repositories get both, plus GitHub Actions on standard runners at no cost, plus secret scanning and push protection.

GitHub Pro ($4/month) adds protected branches to private repositories, but deployment approvals for private repositories still need Enterprise.

## Decision

- One **public** repository (a monorepo) holds the storefront, the API, all Terraform, and the docs.
- Stay on **GitHub Free**.
- Manage the repository's own settings with Terraform (`infra/github/`), so protections are reviewed and reproducible.

## Consequences

- The full feature set is available at no cost, and the repository doubles as a portfolio.
- Anything committed is public. That's acceptable because:
  - no long-lived credentials exist (GitHub Actions gets AWS credentials through OIDC),
  - Terraform state and customer data are never stored in git,
  - secret scanning, push protection and a local gitleaks hook all guard against leaks.
- AWS account IDs and resource names will be visible. AWS doesn't treat account IDs as secret, but they're passed in as variables where practical.
- A monorepo means one place for issues, one CI pipeline, and changes that touch the app and its infrastructure together land in one pull request.
- No code license is chosen yet, so by default all rights are reserved. Revisit if others ever want to reuse the code.
