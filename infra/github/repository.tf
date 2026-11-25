# -----------------------------------------------------------------------------
# The repository itself
# -----------------------------------------------------------------------------

# You create the repository by hand with one `gh repo create` command (it has
# to exist before you can push code to it). This block then tells Terraform to
# adopt that existing repository instead of trying to create a new one.
#
# After the first successful apply the block does nothing; it stays here to
# record where the resource came from. You'll use the same technique for the
# madeinedmonds.com DNS zone that already exists in AWS.
import {
  to = github_repository.site
  id = var.repository_name
}

resource "github_repository" "site" {
  name         = var.repository_name
  description  = "Made in Edmonds: handmade wooden pet urns. Storefront, AWS infrastructure (Terraform), and runbooks, built in public."
  homepage_url = "https://${var.site_domain}"
  visibility   = "public"
  topics       = ["terraform", "aws", "sre", "ecommerce", "react", "typescript", "github-actions"]

  # --- Features ---------------------------------------------------------------
  has_issues      = true  # Track work and bugs.
  has_projects    = true  # Roadmap board.
  has_wiki        = false # Docs live in /docs and are reviewed in PRs like code.
  has_discussions = false # Solo project; nothing to discuss with yet.

  # --- How pull requests merge ------------------------------------------------
  # Squash only: every pull request becomes exactly one commit on main, titled
  # after the PR. A clean, linear history is much easier to read during an
  # incident ("what changed right before it broke?") and to revert.
  allow_squash_merge          = true
  allow_merge_commit          = false
  allow_rebase_merge          = false
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  allow_auto_merge       = true # "Merge when checks pass" button, handy for Dependabot PRs.
  allow_update_branch    = true # "Update branch" button when main has moved on.
  delete_branch_on_merge = true # Merged branches are cleaned up automatically.

  # --- Security ---------------------------------------------------------------
  # Dependabot alerts: GitHub tells you when a dependency has a known
  # vulnerability.
  vulnerability_alerts = true

  # Secret scanning finds credentials committed to the repo; push protection
  # blocks the push before a secret ever reaches GitHub. Both are free for
  # public repositories. (Don't add an `advanced_security` block: the API
  # rejects it for public repos.)
  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  # --- Safety -----------------------------------------------------------------
  # If this resource is ever removed from the config, archive the repository
  # instead of deleting it, and refuse to plan a destroy at all.
  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

# Dependabot security updates: when an alert fires, Dependabot opens a pull
# request that upgrades the vulnerable dependency. (Routine version updates are
# configured separately in .github/dependabot.yml.)
resource "github_repository_dependabot_security_updates" "site" {
  repository = github_repository.site.name
  enabled    = true
}
