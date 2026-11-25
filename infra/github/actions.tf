# -----------------------------------------------------------------------------
# GitHub Actions permissions
#
# A workflow step like `uses: someone/some-action@v1` runs someone else's code
# with access to your repository, and later to your AWS deploy role. This
# limits which actions can run to: GitHub's own, Marketplace "verified
# creators", and the explicit list below.
#
# The default GITHUB_TOKEN for new personal repositories is already read-only,
# and every workflow here also declares its own minimal `permissions:` block.
# -----------------------------------------------------------------------------

resource "github_actions_repository_permissions" "site" {
  repository      = github_repository.site.name
  enabled         = true
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true # actions/checkout, actions/cache, ...
    verified_allowed     = true # Marketplace verified creators.

    # Named explicitly too, so they keep working even if a publisher's
    # verified badge ever changes.
    patterns_allowed = [
      "hashicorp/setup-terraform@*",
      "aws-actions/configure-aws-credentials@*",
    ]
  }
}
