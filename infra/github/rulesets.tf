# -----------------------------------------------------------------------------
# Branch ruleset: the rules that protect `main`
#
# `main` is what gets deployed, so nothing lands on it without a pull request
# and a green CI run. These rules apply to you too: there are deliberately no
# bypass actors. If CI itself is broken and you must merge a fix, follow the
# break-glass steps in docs/setup/01-github.md.
# -----------------------------------------------------------------------------

resource "github_repository_ruleset" "main" {
  name        = "protect-main"
  repository  = github_repository.site.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      # ~DEFAULT_BRANCH follows the default branch even if it's ever renamed.
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    # Nobody can delete main.
    deletion = true

    # No force pushes: history on main can't be rewritten.
    non_fast_forward = true

    # No merge commits on main. Works together with squash-only merging.
    required_linear_history = true

    # Commit signing isn't required here on purpose: with it on, GitHub only
    # lets a PR's own author squash-merge it, which would block merging
    # Dependabot's PRs. You still sign your own commits locally (setup guide,
    # step 4), so they show as "Verified".

    pull_request {
      # 0 approvals: you can't approve your own PR, and you're the only
      # developer. Requiring a PR still forces every change through CI and
      # leaves a written record of what changed and why.
      required_approving_review_count = 0
      dismiss_stale_reviews_on_push   = true
      require_code_owner_review       = false
      require_last_push_approval      = false

      # Any review comment (yours, or an automated reviewer's) has to be
      # resolved before merging.
      required_review_thread_resolution = true
    }

    required_status_checks {
      # The branch must be up to date with main before merging, so CI has
      # tested exactly what will land.
      strict_required_status_checks_policy = true

      # One gate job in .github/workflows/ci.yml that only passes when every
      # other CI job passed. New CI jobs get added to that job's `needs` list,
      # so this ruleset never has to change.
      #
      # integration_id 15368 is the GitHub Actions app: only a real Actions
      # run can satisfy this check, not a status posted by another tool.
      required_check {
        context        = "ci-passed"
        integration_id = 15368
      }
    }
  }
}
