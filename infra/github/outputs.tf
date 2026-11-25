output "repository_url" {
  description = "Web address of the repository."
  value       = github_repository.site.html_url
}

output "ssh_clone_url" {
  description = "Use this to clone the repository on another machine."
  value       = github_repository.site.ssh_clone_url
}

output "ruleset_id" {
  description = "ID of the protect-main ruleset (Settings > Rules > Rulesets)."
  value       = github_repository_ruleset.main.ruleset_id
}

output "environments" {
  description = "Deployment environments that workflows can target."
  value       = [github_repository_environment.staging.environment, github_repository_environment.production.environment]
}
