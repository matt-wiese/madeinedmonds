# infra/github

Terraform that manages this repository's own GitHub settings.

| File | Manages |
|---|---|
| `repository.tf` | The repository: features, merge options, security features. Adopted with an `import` block. |
| `rulesets.tf` | `protect-main`: PR required, CI must pass, no force pushes or deletion. |
| `environments.tf` | `staging` and `production` deployment environments; production needs your approval. |
| `actions.tf` | Which GitHub Actions are allowed to run. |

## Running it

```sh
# In a terminal where GITHUB_TOKEN is set using 'read -rs GITHUB_TOKEN && export GITHUB_TOKEN'
terraform -chdir=infra/github init
terraform -chdir=infra/github plan
terraform -chdir=infra/github apply
```

## Changing a setting

1. Edit the `.tf` file on a branch and open a pull request. CI checks formatting and validates the config.
2. After merging, update your local `main` and run `terraform -chdir=infra/github apply`.

If you change a setting in the GitHub web UI instead, the next `plan` shows it as drift and `apply` puts it back. The code is the source of truth.

State is local for now (`terraform.tfstate`, git-ignored). It moves to S3 in the AWS setup step.
