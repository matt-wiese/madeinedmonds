# -----------------------------------------------------------------------------
# Deployment environments
#
# A GitHub Actions job that says `environment: production` has to pass that
# environment's rules before it runs. In the AWS step, the AWS deploy roles
# will trust *only* jobs running in these environments (GitHub includes the
# environment name in the identity token it gives AWS). That links three
# protections together:
#
#   code reached main via a reviewed, green PR      (rulesets.tf)
#   -> the job only runs from main, and production waits for your approval
#   -> AWS only accepts credentials requests from that environment
# -----------------------------------------------------------------------------

# Looks up your numeric GitHub user ID, needed for the reviewer list below.
data "github_user" "me" {
  username = var.github_owner
}

# --- staging ------------------------------------------------------------------
# Deploys automatically, but only from main.
resource "github_repository_environment" "staging" {
  repository  = github_repository.site.name
  environment = "staging"

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true # Allowed branches are listed below.
  }
}

resource "github_repository_environment_deployment_policy" "staging_main" {
  repository     = github_repository.site.name
  environment    = github_repository_environment.staging.environment
  branch_pattern = "main"
}

# --- production ---------------------------------------------------------------
# Only from main, and every deployment waits until you click "Approve".
resource "github_repository_environment" "production" {
  repository  = github_repository.site.name
  environment = "production"

  reviewers {
    users = [tonumber(data.github_user.me.id)]
  }

  # You're the only reviewer, so you have to be allowed to approve deploys you
  # started. Turn this on once someone else can review.
  prevent_self_review = false

  # Even repository admins (you) can't skip the approval step.
  can_admins_bypass = false

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "production_main" {
  repository     = github_repository.site.name
  environment    = github_repository_environment.production.environment
  branch_pattern = "main"
}
