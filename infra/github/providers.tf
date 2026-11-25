# The GitHub provider talks to the GitHub API on your behalf.
#
# Authentication: the provider reads a token from the GITHUB_TOKEN environment
# variable. Never put the token in a .tf or .tfvars file: those are committed
# to a public repository. See docs/setup/01-github.md, step 8.
provider "github" {
  owner = var.github_owner
}
