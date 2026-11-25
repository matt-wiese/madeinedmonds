# Security policy

## Reporting a vulnerability

Please **don't open a public issue** for a security problem.

Report it privately through GitHub instead: go to the **Security** tab of this repository and click **Report a vulnerability**. Only the maintainer can see the report.

You can expect an acknowledgement within 3 days. Please include steps to reproduce if you can.

## Scope

In scope: this repository's code and configuration, and the madeinedmonds.com site and its API.

Out of scope: Stripe's hosted checkout pages and other third-party services (report those to the provider), and denial-of-service or load testing against the live site.

## How this repository protects itself

- No long-lived cloud credentials exist: GitHub Actions gets short-lived AWS credentials through OIDC.
- Secret scanning and push protection are on; gitleaks runs before every local commit.
- `main` can only change through a pull request that passes CI. Production deploys need manual approval.
- Terraform state is never stored in this repository.
