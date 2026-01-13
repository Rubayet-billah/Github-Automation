#!/bin/bash
# Run with: ./multi-cherry-pick.sh

# =========================================================
# 🔘 OPERATION TOGGLES (JS-style)
# 👉 Set ONLY ONE to true at a time
# =========================================================
# DO_PULL=true
# DO_CHERRY_PICK=true
# DO_DELETE_DEPLOY=true
# DO_CREATE_DEV=true
# DO_DELETE_BRANCH=false
DO_CREATE_PR=true

# =========================================================
# 📦 CONFIG
# =========================================================
branches=(
  # "dim"
  # "mra"
  # "amr-new-theme"
  # "amr-new-dev"
  # "mrf"
  # "pmr"
  # "mir"

  # "imr"
  "tir"
  "nrp"
  "dmv"
  "mdp"
  "msr"
  # "dir"
  # "vdr"
  # "rax"
  # "pmv"
  # "pri"
)

commits=(
  "1783554bd3eb8d81216ba3c7ed2e047929efe9e9"
  "6f5aacee0d12a8f9577f9cf630d9b85d9c8f1799"
  "d4079c838881b6873ecf4dae0f27b440535c489f"
  "a48cdbc526afd075b021c0ac7299fdba3861d29f"
)

FILE_TO_DELETE=".github/workflows/deploy.yml"

# =========================================================
# 📝 PR CONFIG (VARIABLE)
# =========================================================
PR_TITLE="Dev → Main sync"
PR_BODY="Home, RD page optimized and sitemap updated"

# =========================================================
# 🛡️ SAFETY CHECK (allow only ONE operation)
# =========================================================
enabled=0

[ "$DO_PULL" = true ] && ((enabled++))
[ "$DO_CHERRY_PICK" = true ] && ((enabled++))
[ "$DO_DELETE_DEPLOY" = true ] && ((enabled++))
[ "$DO_CREATE_DEV" = true ] && ((enabled++))
[ "$DO_DELETE_BRANCH" = true ] && ((enabled++))
[ "$DO_CREATE_PR" = true ] && ((enabled++))

if (( enabled == 0 )); then
  echo "❌ No operation selected. Set one DO_* flag to true."
  exit 1
fi

if (( enabled > 1 )); then
  echo "❌ Multiple operations enabled!"
  echo "👉 Enable ONLY ONE DO_* flag at a time."
  exit 1
fi

# =========================================================
# 🧠 FUNCTIONS
# =========================================================

pull_branches() {
  for branch in "${branches[@]}"; do
    echo "📥 Pulling latest for: $branch"
    git checkout "$branch"
    git pull origin "$branch"
  done
}

cherry_pick_commits() {
  for branch in "${branches[@]}"; do
    echo "🔀 Cherry-picking on: $branch"
    git checkout "$branch"
    git pull origin "$branch"

    for commit in "${commits[@]}"; do
      git cherry-pick "$commit" || {
        echo "⚠️ Cherry-pick failed on $branch"
        git cherry-pick --abort
        break
      }
    done

    git push origin "$branch"
  done
}

delete_deploy_file() {
  for branch in "${branches[@]}"; do
    echo "🗑️ Removing deploy.yml from: $branch"
    git checkout "$branch"
    git pull origin "$branch"

    if [ -f "$FILE_TO_DELETE" ]; then
      git rm "$FILE_TO_DELETE"
      git commit -m "chore: remove deploy pipeline to prevent auto deploy"
      git push origin "$branch"
      echo "✅ deploy.yml removed from $branch"
    else
      echo "ℹ️ deploy.yml not found in $branch"
    fi
  done
}

create_dev_branches() {
  for branch in "${branches[@]}"; do
    DEV_BRANCH="${branch}-dev"

    echo "🌱 Creating dev branch: $DEV_BRANCH from $branch"

    git checkout "$branch"
    git pull origin "$branch"

    if git ls-remote --heads origin "$DEV_BRANCH" | grep -q "$DEV_BRANCH"; then
      echo "⚠️ $DEV_BRANCH already exists on remote. Skipping."
      continue
    fi

    git checkout -b "$DEV_BRANCH"
    git push -u origin "$DEV_BRANCH"

    echo "✅ Created & pushed $DEV_BRANCH"
  done
}

delete_branches() {
  for branch in "${branches[@]}"; do
    echo "🗑️ Deleting branch: $branch"

    current=$(git branch --show-current)
    if [ "$current" = "$branch" ]; then
      git checkout main 2>/dev/null || git checkout master
    fi

    git branch -D "$branch" 2>/dev/null || echo "⚠️ Local $branch not found"
    git push origin --delete "$branch" 2>/dev/null || echo "⚠️ Remote $branch not found"

    echo "✅ Deleted $branch (local + remote)"
  done
}

# =========================================================
# 🚀 CREATE PRs (dev → main)
# =========================================================
create_pull_requests() {
  if ! command -v gh &>/dev/null; then
    echo "❌ GitHub CLI (gh) not installed."
    echo "👉 Install it from: https://cli.github.com/"
    exit 1
  fi

  for branch in "${branches[@]}"; do
    DEV_BRANCH="${branch}-dev"
    BASE_BRANCH="$branch"

    echo "🔁 Creating PR: $DEV_BRANCH → $BASE_BRANCH"

    if ! git ls-remote --heads origin "$DEV_BRANCH" | grep -q "$DEV_BRANCH"; then
      echo "⚠️ Dev branch $DEV_BRANCH does not exist. Skipping."
      continue
    fi

    # Check if PR already exists
    if gh pr list --head "$DEV_BRANCH" --base "$BASE_BRANCH" --json number | grep -q number; then
      echo "⚠️ PR already exists for $DEV_BRANCH → $BASE_BRANCH"
      continue
    fi

    gh pr create \
      --base "$BASE_BRANCH" \
      --head "$DEV_BRANCH" \
      --title "$BASE_BRANCH ⬅️ $DEV_BRANCH" \
      --body "$PR_BODY" \
      --draft

    echo "✅ PR created: $DEV_BRANCH → $BASE_BRANCH"
  done
}


# =========================================================
# 🚦 EXECUTION
# =========================================================
[ "$DO_PULL" = true ] && pull_branches
[ "$DO_CHERRY_PICK" = true ] && cherry_pick_commits
[ "$DO_DELETE_DEPLOY" = true ] && delete_deploy_file
[ "$DO_CREATE_DEV" = true ] && create_dev_branches
[ "$DO_DELETE_BRANCH" = true ] && delete_branches
[ "$DO_CREATE_PR" = true ] && create_pull_requests

echo "🎉 Operation completed successfully!"
