# Contributing to Made in Edmonds

Thanks for taking the time to look. This repository runs a real (small) shop that makes wooden urns for people who have lost a pet, and it's also a learning project built in public. Contributions are welcome, and this page explains how to make one that's easy to review and merge.

## What's welcome

- Bug fixes and typo fixes
- Improvements to documentation, accessibility, or tests
- Suggestions for the Terraform, CI, or reliability setup, ideally with a short explanation of why

**Please open an issue first** for anything bigger than a small fix: a new feature, a new dependency, or any change under `infra/` or `.github/`. A quick conversation up front saves you from writing something that can't be merged.

Product, pricing, and brand decisions aren't open for contribution, but feedback in an issue is always welcome.

## Security issues

Don't open a public issue or pull request for a vulnerability. Follow [SECURITY.md](SECURITY.md) to report it privately.

## License

This repository doesn't have an open-source license yet. Until it does, please open an issue before starting on a code contribution, so we can agree on how it will be licensed.

## Setting up

You'll need:

- `git`
- `terraform` 1.17.x (CI uses the version pinned in `.github/workflows/ci.yml`)
- `pre-commit` ([install instructions](https://pre-commit.com/#install))

Then:

1. Fork the repository on GitHub and clone your fork.
2. Install the commit hooks, which run the same quick checks as CI every time you commit:

   ```sh
   pre-commit install
   ```

## Making a change

1. Create a branch from `main` with a short descriptive name, like `fix/typo-in-readme` or `docs/clarify-setup`.
2. Keep each pull request focused on one thing. Small PRs get reviewed faster.
3. Run the checks before you push:

   ```sh
   pre-commit run --all-files
   terraform fmt -check -recursive
   terraform -chdir=infra/github init -backend=false
   terraform -chdir=infra/github validate
   ```

You can't run `terraform plan` or `apply` against the real GitHub settings or AWS accounts, and that's fine: `validate` checks your change is correct, and the maintainer runs the plan after reviewing it.

### Changes that get extra scrutiny

Anything under `.github/workflows/` or `infra/` changes what runs with this project's permissions or what gets deployed. Expect careful review, and please:

- Use only actions from GitHub, Marketplace verified creators, or the allowed list in `infra/github/actions.tf`. Others are blocked and the workflow will fail.
- Never use the `pull_request_target` trigger. It runs with the repository's own permissions, so combined with code from a pull request it's a well-known way to compromise a project.
- Give every workflow the smallest `permissions:` it needs.

### Never commit secrets

No API keys, tokens, passwords, or `.env` files. The pre-commit hooks and GitHub's push protection both scan for secrets, but please don't rely on them.

## Opening the pull request

- **Title:** use a [Conventional Commits](https://www.conventionalcommits.org/) prefix: `fix:`, `feat:`, `docs:`, `infra:`, `ci:`, or `chore:`. Pull requests are squash-merged, so the title becomes the commit message on `main`.
- **Description:** fill in the template: what changed, why, how you checked it, and how to undo it if needed.
- **Tick "Allow edits by maintainers."** `main` requires every PR to be up to date before it merges. With this box ticked, the maintainer can update your branch for you instead of asking you to.

## What happens next

1. **CI needs approval to start.** For security, workflows from outside contributors only run after the maintainer approves them, so your checks may show as waiting for a while.
2. **Review.** Expect a first response within a week. This is a one-person project, so please be patient.
3. **Merge.** Once the `ci-passed` check is green and review comments are resolved, the PR is squash-merged into `main`.

## Using AI tools

That's fine, but you're responsible for the result: please only submit changes you understand line by line and have run the checks on. Mention in the PR description if a tool wrote a significant part of it. Pull requests that look like unreviewed bulk output will be closed.

## Be kind

Be respectful in issues and reviews. The people this shop serves are often grieving, so please keep any wording that customers might see gentle and plain.
