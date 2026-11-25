variable "github_owner" {
  description = "Your GitHub username. The repository lives under this account."
  type        = string

  validation {
    condition     = length(var.github_owner) > 0 && !startswith(var.github_owner, "YOUR_")
    error_message = "Set github_owner in terraform.tfvars to your real GitHub username."
  }
}

variable "repository_name" {
  description = "Name of the repository that holds the site, infrastructure and docs. Must match the repository you created with `gh repo create`."
  type        = string
  default     = "madeinedmonds"
}

variable "site_domain" {
  description = "The shop's domain, shown as the repository's website link."
  type        = string
  default     = "madeinedmonds.com"
}
