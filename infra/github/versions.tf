# -----------------------------------------------------------------------------
# Terraform and provider versions
#
# This folder is a "root module": a folder you run `terraform init/plan/apply`
# in. It manages the settings of this GitHub repository itself, so every
# protection on `main` is written down, reviewed in pull requests, and can be
# rebuilt from scratch.
# -----------------------------------------------------------------------------

terraform {
  # 1.10 or newer: import blocks with expressions (1.6+) and S3-native state
  # locking (1.10+), which we switch to once the AWS state bucket exists.
  required_version = ">= 1.10.0"

  required_providers {
    github = {
      # "~> 6.12" means any 6.x release from 6.12 up, but never 7.0, which
      # could contain breaking changes. Dependabot opens a PR when a new
      # version comes out.
      source  = "integrations/github"
      version = "~> 6.12"
    }
  }

  # State is stored locally for now, in terraform.tfstate next to this file
  # (git-ignored). In the AWS step we add a `backend "s3"` block here and run
  # `terraform init -migrate-state` to move it into S3.
}
