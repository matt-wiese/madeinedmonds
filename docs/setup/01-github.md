# 01: GitHub setup

**Goal:** a secured GitHub account and a public `madeinedmonds` repository whose protections are managed by Terraform. This is also your first Terraform project: it's free, it can't break anything expensive, and every concept carries straight over to AWS.

**Time:** about 2 to 3 hours the first time.

**When you're done you'll have:**

- [ ] Two-factor authentication on, and your email address kept private
- [ ] One SSH key used both to push code and to sign commits (they show as **Verified**)
- [ ] `git`, `gh`, `terraform` and `pre-commit` installed
- [ ] The repository pushed to GitHub, with CI running on every change
- [ ] `main` protected: changes only through a pull request with a green CI run
- [ ] `staging` and `production` deployment environments, with production gated on your approval
- [ ] Every repository setting above stored as code in `infra/github/`

Commands are for macOS and Linux. On Windows, install WSL2 (`wsl --install` in an administrator PowerShell, then reboot) and run everything inside the Ubuntu terminal it gives you, following the Linux instructions.

---

## Step 1: Secure your GitHub account

These are account-level settings that Terraform can't manage, so you click through them once.

### 1a. Two-factor authentication

1. Open **Settings → Password and authentication**.
2. Under **Two-factor authentication**, click **Enable** and choose an **authenticator app** (1Password, Google Authenticator, Authy, ...).
3. **Save the recovery codes in a password manager.** If you lose your phone, they're the only way back into your account.
4. On the same page, under **Passkeys**, add a passkey (Touch ID, Windows Hello, or a security key). It's faster and phishing-proof.

*Why:* this repository will hold the keys to your production infrastructure (deploy permissions, AWS trust). Your GitHub login is now a production credential.

### 1b. Keep your email address private

1. Open **Settings → Emails**.
2. Tick **Keep my email addresses private**.
3. Tick **Block command line pushes that expose my email**.
4. Copy the `...@users.noreply.github.com` address shown on that page. It looks like `12345678+yourname@users.noreply.github.com`. You'll use it in step 4.

*Why:* every commit records an email address, and in a public repository anyone can read it. The noreply address still links commits to your account.

---

## Step 2: Install the tools

**macOS** (install [Homebrew](https://brew.sh) first if you don't have it):

```sh
brew install git gh pre-commit
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux / WSL (Ubuntu):**

- git and pipx: `sudo apt update && sudo apt install -y git pipx unzip && pipx ensurepath`
- gh: follow the Debian/Ubuntu instructions at <https://github.com/cli/cli/blob/trunk/docs/install_linux.md>
- Terraform: follow the Ubuntu/Debian instructions at <https://developer.hashicorp.com/terraform/install>
- pre-commit: `pipx install pre-commit`

**Check the versions:**

```sh
git --version        # needs 2.34 or newer (SSH commit signing arrived in 2.34)
gh --version
terraform version    # 1.17.x at the time of writing
pre-commit --version
```

If `terraform version` isn't `1.17.2`, change `terraform_version` in `.github/workflows/ci.yml` (after step 6a) to match, so CI checks your code with the same version you run.

---

## Step 3: Create an SSH key for pushing and signing

One key does two jobs: it proves who you are when you push (authentication), and it signs your commits so GitHub can show they really came from you (signing).

```sh
ssh-keygen -t ed25519 -C "github-$(hostname)" -f ~/.ssh/id_ed25519_github
```

Give it a passphrase when asked. The SSH agent remembers it, so you won't type it on every push.

**Load the key into the SSH agent and tell SSH to use it for GitHub:**

macOS:

```sh
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_github

cat >> ~/.ssh/config <<'EOF'
Host github.com
  IdentityFile ~/.ssh/id_ed25519_github
  AddKeysToAgent yes
  UseKeychain yes
EOF
```

Linux / WSL:

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_github

cat >> ~/.ssh/config <<'EOF'
Host github.com
  IdentityFile ~/.ssh/id_ed25519_github
  AddKeysToAgent yes
EOF
```

**Add the public key to GitHub, twice:**

1. Print it: `cat ~/.ssh/id_ed25519_github.pub` and copy the whole line.
2. Open **Settings → SSH and GPG keys → New SSH key**. Title: your computer's name. **Key type: Authentication Key**. Paste, save.
3. Click **New SSH key** again with the same key, but **Key type: Signing Key**. Paste, save.

**Test it:**

```sh
ssh -T git@github.com
# Hi yourname! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## Step 4: Configure git

Replace the name and the noreply address with yours (from step 1b):

```sh
git config --global user.name  "Your Name"
git config --global user.email "12345678+yourname@users.noreply.github.com"

# New repositories start on a branch called main
git config --global init.defaultBranch main

# Sign every commit and tag with your SSH key
git config --global gpg.format ssh
git config --global user.signingkey "$HOME/.ssh/id_ed25519_github.pub"
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# `git pull` only fast-forwards, so it never creates surprise merge commits
git config --global pull.ff only
```

*Optional:* **Settings → SSH and GPG keys → Vigilant mode** flags any unsigned commit made under your name as **Unverified**.

---

## Step 5: Log in with the GitHub CLI

```sh
gh auth login
```

Answer the prompts:

| Prompt | Answer |
|---|---|
| Where do you use GitHub? | **GitHub.com** |
| Preferred protocol for Git operations? | **SSH** |
| Upload your SSH public key? | **Skip** (you added it in step 3) |
| How would you like to authenticate? | **Login with a web browser** |

Check it worked: `gh auth status`.

---

## Step 6: Unpack the scaffold and create the repository

### 6a. Unpack and personalize

```sh
cd ~/git
unzip ~/Downloads/madeinedmonds-scaffold.zip   # creates ~/git/madeinedmonds
cd madeinedmonds
```

Put your GitHub username into the files that need it (`CODEOWNERS`, `infra/github/terraform.tfvars`, the README badge):

```sh
GH_USER=yourname   # your actual GitHub username

grep -rl --exclude-dir=docs YOUR_GITHUB_USERNAME . \
  | xargs perl -pi -e "s/YOUR_GITHUB_USERNAME/$GH_USER/g"

# Should print nothing:
grep -rn --exclude-dir=docs YOUR_GITHUB_USERNAME .
```

### 6b. Check the Terraform before the first commit

This downloads the GitHub provider and checks the configuration, without touching GitHub:

```sh
terraform fmt -recursive
terraform -chdir=infra/github init -backend=false
terraform -chdir=infra/github validate
# Success! The configuration is valid.
```

`init` created `infra/github/.terraform.lock.hcl`, which records the exact provider version and its checksums. Add checksums for the other platforms you and CI use, so the lock file works everywhere:

```sh
terraform -chdir=infra/github providers lock \
  -platform=linux_amd64 -platform=darwin_arm64 -platform=darwin_amd64
```

The lock file gets committed; the `.terraform/` folder (the downloaded provider) is git-ignored.

### 6c. First commit and push

Still inside `~/git/madeinedmonds`. `~/git` is just a plain folder that holds your projects; each project inside it, like this one, gets its own repository:

```sh
git init
git add .
git status    # review: no .terraform/ folder, no .tfstate files
git commit -m "chore: initial repository scaffold"
```

Create the repository on GitHub and push, in one command:

```sh
gh repo create madeinedmonds --public --source=. --remote=origin --push \
  --description "Made in Edmonds: handmade wooden pet urns. Built in public."
```

Open it with `gh repo view --web` and check:

- The commit shows a green **Verified** badge. If it says **Unverified**, see Troubleshooting.
- The **Actions** tab shows a CI run for that push. It should go green in about a minute.

At this moment `main` isn't protected yet: that's step 9.

---

## Step 7: Turn on the pre-commit hooks

```sh
pre-commit install
pre-commit run --all-files
```

The first run takes a minute or two while it downloads the hooks. You'll see `don't commit to branch ... Failed` because you're on `main`: that's expected. It's the hook that stops you committing to `main` by accident. Everything else should say `Passed`. If a hook says it fixed a file, leave the change in place and include it in your first pull request in step 10b.

From now on, every `git commit` first runs these checks: whitespace fixes, YAML syntax, large-file and private-key detection, `terraform fmt`, and a gitleaks secret scan. If a hook changes a file (for example `terraform fmt`), the commit stops; `git add` the file and commit again.

---

## Step 8: Create a token for Terraform

Terraform needs its own credential to change repository settings. A **fine-grained personal access token** limited to this one repository is the least-privilege option.

1. Open **Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**.
2. Fill in:

   | Field | Value |
   |---|---|
   | Token name | `terraform-madeinedmonds-github` |
   | Expiration | 90 days (put a reminder in your calendar to rotate it) |
   | Resource owner | your account |
   | Repository access | **Only select repositories → madeinedmonds** |
   | Repository permissions → **Administration** | **Read and write** |
   | Repository permissions → **Contents** | **Read-only** |
   | Repository permissions → **Metadata** | Read-only (added automatically) |

3. Click **Generate token**, copy it, and save it in your password manager.

**Load it into your terminal** without it ending up in your shell history:

```sh
read -rs GITHUB_TOKEN && export GITHUB_TOKEN
# Paste the token and press Enter. Nothing is shown; that's on purpose.
```

This lasts until you close the terminal. In a new terminal, run it again.

*Why not `gh auth token`?* It works, but that token can change every repository you own, and it doesn't expire. If it leaked, the damage would be far wider.

---

## Step 9: Apply the GitHub configuration with Terraform

### 9a. Initialize and plan

```sh
terraform -chdir=infra/github init
terraform -chdir=infra/github plan
```

**Read the plan carefully. It's the most important habit in this whole project.** You should see:

- `github_repository.site` **will be imported**: Terraform adopts the repository you created in step 6c, because of the `import` block in `repository.tf`. It may also show a few settings being **updated in place** (`~`), where your new repository's defaults differ from the config.
- About 7 resources **will be created** (`+`): the Dependabot security updates setting, the `protect-main` ruleset, the two environments with their branch policies, and the Actions permissions.
- A summary line like `Plan: 1 to import, 7 to add, 1 to change, 0 to destroy.`

**Stop if you see `destroy` or `must be replaced`** for the repository. That means the import didn't match; check `github_owner` and `repository_name`.

### 9b. Apply

```sh
terraform -chdir=infra/github apply
```

Terraform shows the plan again and asks for confirmation. Type `yes`. At the end it prints the outputs: the repository URL, the ruleset ID, and the two environments.

### 9c. Prove nothing has drifted

```sh
terraform -chdir=infra/github plan
# No changes. Your infrastructure matches the configuration.
```

That "No changes" is the core promise of infrastructure as code: what's in the files is exactly what's running. You'll run this check constantly.

Your state now lives in `infra/github/terraform.tfstate` (git-ignored). Don't delete it. If you ever lose it, you can rebuild it with import blocks, but it's tedious. It moves to S3 in the AWS step.

---

## Step 10: Check that the protections work

### 10a. A direct push to main is rejected

```sh
git commit --allow-empty --no-verify -m "test: direct push to main"
git push
# remote: error: GH013: Repository rule violations found for refs/heads/main.
# remote: - Changes must be made through a pull request.
```

That rejection is the point. Undo the test commit (any other uncommitted edits are kept):

```sh
git reset HEAD~1
```

### 10b. Your first pull request

```sh
git switch -c docs/github-setup-done
```

Edit `README.md` and change the status line to say GitHub setup is done. Then:

```sh
git commit -am "docs: GitHub setup complete"
git push -u origin HEAD      # first push of a new branch
gh pr create --fill          # opens the PR using your commit message
gh pr checks --watch         # watch CI; ci-passed must turn green
gh pr merge --squash --delete-branch
git switch main && git pull
```

### 10c. Look at the settings pages

On GitHub, under the repository's **Settings**:

- **Rules → Rulesets:** `protect-main` is **Active**.
- **Environments:** `staging` and `production`. Production lists you as required reviewer and only allows `main`.
- **Actions → General:** under **Actions permissions**, the option that allows a selected list of actions is chosen, with GitHub-owned and verified-creator actions ticked and the `hashicorp/setup-terraform@*` and `aws-actions/configure-aws-credentials@*` patterns listed. Under **Workflow permissions**, check that **Read repository contents and packages permissions** is selected and **Allow GitHub Actions to create and approve pull requests** is unticked (the defaults for new repositories).
- **Advanced Security** (or **Code security**): Dependabot alerts and security updates on; secret scanning and push protection on.

---

## Step 11: Settings Terraform doesn't manage

Click these once:

1. **Private vulnerability reporting:** repository **Settings → Advanced Security** (or **Code security**) → **Private vulnerability reporting → Enable**. `SECURITY.md` tells people to use it.
2. **Notifications:** account **Settings → Notifications**. Under **Actions**, choose to be notified only for failed workflows. Under **Dependabot alerts**, make sure email is on.
3. **Profile (optional):** on your profile page, **Customize your pins** and pin `madeinedmonds`. It's your portfolio piece.

---

## Day-to-day workflow

Every change, from a typo to a new AWS service, goes the same way:

```sh
git switch main && git pull                # start from the latest main
git switch -c feat/short-description       # one branch per change
# ...edit...
git add -p                                 # review each change as you stage it
git commit -m "feat: add product page"
git push -u origin HEAD
gh pr create --fill
gh pr checks --watch
gh pr merge --squash --delete-branch       # or --auto to merge once CI is green
git switch main && git pull
```

**Commit message prefixes** (Conventional Commits): `feat:` new feature, `fix:` bug fix, `infra:` Terraform, `ci:` workflows, `docs:` documentation, `chore:` housekeeping. Because PRs are squash-merged, the **PR title** becomes the commit on `main`, so give PRs the same kind of title.

### Changing a GitHub setting

1. Edit the right file in `infra/github/` on a branch, then open a PR. CI checks the format and validates the config.
2. After merging, pull `main`, load your token (step 8), then run `plan` and `apply`.

If you ever change a setting by clicking in the web UI instead, the next `plan` shows the difference and `apply` reverts it. Keep the code as the source of truth.

---

## Break-glass: CI is broken and you must merge a fix

The ruleset has no bypass, on purpose. If CI itself breaks (a bad workflow change, or a GitHub Actions outage) and a fix can't get a green check:

1. **Settings → Rules → Rulesets → protect-main → Enforcement status: Disabled → Save.**
2. Merge the fix.
3. Set it back to **Active**, or run `terraform -chdir=infra/github apply`, which restores it.
4. Write a few lines about what happened in `docs/incidents/YYYY-MM-DD-short-name.md`: what broke, how you noticed, what you did. That's your first postmortem.

---

## Troubleshooting

| Problem | Cause and fix |
|---|---|
| Commits show **Unverified** | The key wasn't added as a **Signing Key** (step 3), or `user.email` isn't an address on your account. Use the noreply address from step 1b. |
| `push declined due to email privacy restrictions` | `user.email` is your real address. Set it to the noreply address (step 4) and re-commit with `git commit --amend --reset-author --no-edit`. |
| `Permission denied (publickey)` | The key isn't loaded: run the `ssh-add` command from step 3, then `ssh -T git@github.com`. |
| Terraform: `Set github_owner in terraform.tfvars` | The username replacement in step 6a didn't run. Edit `infra/github/terraform.tfvars`. |
| Terraform: `401 Bad credentials` | `GITHUB_TOKEN` isn't set in this terminal, or it expired. Repeat step 8's `read` command. |
| Terraform: `403 Resource not accessible by personal access token` | The token is missing a permission or the repository. The error names the API call; edit the token (step 8) and add the permission. **Administration: Read and write** is the usual one. |
| Terraform: `Cannot import non-existent remote object` | The owner, the repository name, or the token's repository access doesn't match the repository you created. |
| Terraform error mentioning `security_and_analysis` or `advanced_security` | GitHub rejected that block. These features are on by default for public repositories, so delete the `security_and_analysis { ... }` block in `repository.tf`, apply again, and check the settings page from step 10c. |
| PR stuck at **ci-passed: Expected — Waiting for status to be reported** | The CI workflow didn't run. Look in the **Actions** tab: is the workflow file on your branch? Did the allowed-actions list block an action? |
| `GH013: Repository rule violations found` | Expected when pushing to `main`. Push to a branch and open a PR. |
| CI fails at **Check formatting** | Run `terraform fmt -recursive` locally, commit, push. The pre-commit hook normally catches this first. |

---

## Reference: every setting and why

### Account

| Setting | Value | Why |
|---|---|---|
| Two-factor authentication | Authenticator app + passkey | Your GitHub login controls production deploys |
| Email privacy | On, and block pushes that expose it | Commits in a public repo would otherwise publish your email |
| SSH authentication key | ed25519, passphrase-protected | Push without passwords or long-lived tokens |
| SSH signing key | Same key | Commits show **Verified**, proving they came from you |
| Vigilant mode | Optional | Makes any unsigned commit under your name stand out |

### Repository (`infra/github/repository.tf`)

| Setting | Value | Why |
|---|---|---|
| Visibility | Public | Free branch protection, deployment approvals and Actions minutes; portfolio |
| Issues / Projects | On | Track work and the roadmap |
| Wiki / Discussions | Off | Docs live in `docs/` and get reviewed like code |
| Merge methods | Squash only, PR title as commit title | One commit per PR keeps `main` easy to read and revert |
| Auto-merge | On | Queue a merge to happen when CI goes green |
| Update branch button | On | Bring a PR up to date with `main` in one click |
| Delete branch on merge | On | No pile-up of stale branches |
| Dependabot alerts | On | Know when a dependency has a known vulnerability |
| Dependabot security updates | On | Get a PR that fixes it |
| Secret scanning + push protection | On | Block credentials before they're published |
| Archive on destroy + `prevent_destroy` | On | Terraform can never delete the repository |

### `protect-main` ruleset (`infra/github/rulesets.tf`)

| Rule | Value | Why |
|---|---|---|
| Applies to | Default branch | `main` is what gets deployed |
| Bypass list | Empty | Rules apply to you too; break-glass is a deliberate, recorded step |
| Restrict deletions | On | `main` can't be deleted |
| Block force pushes | On | History on `main` can't be rewritten |
| Require linear history | On | No merge commits |
| Require a pull request | On, 0 approvals | Every change goes through CI and leaves a record; solo devs can't self-approve |
| Require conversation resolution | On | Review comments can't be silently ignored |
| Require status checks | `ci-passed` from GitHub Actions, branch up to date | Only code CI tested against the latest `main` can merge |
| Require signed commits | Off | It would block merging Dependabot PRs; you sign your own commits anyway |

### Environments (`infra/github/environments.tf`)

| Environment | Who can deploy | Approval | Why |
|---|---|---|---|
| `staging` | Jobs running from `main` | None | Fast feedback after merging |
| `production` | Jobs running from `main` | You; admins can't bypass | A deliberate human check before customers see a change. AWS will trust only this environment for production deploys. |

### Actions (`infra/github/actions.tf` and `.github/`)

| Setting | Value | Why |
|---|---|---|
| Allowed actions | GitHub-owned, verified creators, plus HashiCorp and AWS by name | Third-party actions run with access to your code and, later, your deploy roles |
| Default `GITHUB_TOKEN` | Read-only (GitHub's default for new personal repos), plus `permissions: contents: read` in every workflow | Least privilege |
| Dependabot | Weekly, Monday 6am Pacific, actions grouped into one PR | Stay current without a flood of PRs |

---

## What's next

**02: AWS foundations.** Lock down the existing AWS account, set up AWS Organizations with `staging` and `production` accounts, create the S3 bucket for Terraform state (and move this folder's state into it), and connect GitHub Actions to AWS through OIDC using the environments you just created.
