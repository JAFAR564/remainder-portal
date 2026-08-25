---
name: gh-cli
description: >-
  Automate GitHub CLI operations including issue management, pull requests,
  triggering GitHub Actions workflows, and downloading release artifacts.
---

# GitHub CLI (gh) Workflow Automation Skill

This skill provides reference commands and automation patterns for leveraging `gh` in mobile and cloud CI environments.

## Essential GitHub CLI Commands

### 1. Workflow Management & Cloud Builds
```bash
# List workflows and recent runs
gh workflow list
gh run list --limit 5

# Trigger a workflow manually (workflow_dispatch)
gh workflow run flutter-build.yml

# Watch real-time execution of the latest run
gh run watch $(gh run list -L 1 --json databaseId -q '.[0].databaseId')

# View logs for a specific run or failure
gh run view --log-failed
```

### 2. Artifact Downloading
```bash
# Download compiled artifacts (e.g., APKs, release binaries)
gh run download -n remainder-portal-apk -D ./build_apk
```

### 3. Pull Requests & Issues
```bash
# Create a pull request
gh pr create --title "feat: descriptive title" --body "Summary of changes"

# View repository status
gh repo view
```
