# 3. Application stack

- **Status:** Accepted
- **Date:** 2026-11-24

## Context

The shop sells a small line of made-to-order wooden pet urns, priced to cover costs. The project's main goal is hands-on full-stack and SRE experience with tools that are widely used in industry, running a real production site on AWS managed by Terraform.

Customers are often grieving. A lost order confirmation or a broken checkout causes real distress, which makes reliability a genuine requirement, not an exercise.

## Decision

| Layer | Choice | Why |
|---|---|---|
| Storefront | React + TypeScript (Vite), static files on S3 behind CloudFront | The most widely used front-end stack; static hosting is cheap and fast |
| API | Node.js + TypeScript in Docker, on ECS Fargate behind an Application Load Balancer | One language across the stack; containers, load balancers and VPC networking are core SRE skills |
| Database | PostgreSQL on RDS | The most widely used database; teaches backups, restores, and migrations |
| Payments | Stripe Checkout + webhooks, Stripe Tax for Washington sales tax | A hosted payment page keeps card data off our servers; webhooks are a pattern reused across many services |
| Email | Amazon SES | Order confirmations and status updates |
| Admin login | Amazon Cognito | Protects the order-management page |
| Infrastructure | Terraform, deployed from GitHub Actions through OIDC | Infrastructure as code with no stored cloud keys |
| AWS accounts | AWS Organizations: management, staging and production accounts | Mistakes in staging can't touch production; cost and access are separated per account |
| Monitoring | CloudWatch logs, metrics, alarms, Synthetics canaries | Built in, enough for SLOs and alerting at this size |

Engraving text is collected on the product page (with a live preview), stored in PostgreSQL, and linked to the Stripe payment by order ID.

## Consequences

- Rough running cost: $45–65/month for production, about the same for staging while it's running. Staging is torn down when not in use.
- Not covered by AWS's new-account credits, because the AWS account already exists.
- These infrastructure costs are treated as the cost of learning. Urn prices cover materials, packaging, shipping and Stripe fees only.
- A serverless design (Lambda + DynamoDB) would be cheaper but would skip networking, containers and relational database operations, which the project specifically wants to practice.
