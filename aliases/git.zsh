alias gad="git add"
alias gal="git add . && git add -u && echo -e \"\033[42m Added all changes: \033[40m\" && gst"
alias gam="git commit --amend"
alias gbr="git branch"
alias gcl="git clean -fd"
alias gco="git checkout"
alias gcm="git commit -m"
alias gdf="git diff"
alias glo="git log"
alias gpl='echo "\e[1;36m↓ Pulling $(git symbolic-ref --short HEAD)\e[0m"; git pull --no-edit'
alias gps='echo "\e[1;36m↑ Pushing $(git symbolic-ref --short HEAD)\e[0m"; git push -u'
alias gst="git status -s"
alias gwa="git worktree add"
alias gwr="git worktree remove"
alias gwl="git worktree list"

# Interactively clean up worktrees (optionally filtered by branch)
function gwcleanup() {
  emulate -L zsh
  setopt localoptions noxtrace
  set +x
  set +v

  local branch_filter=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "\e[1;33mInteractively delete git worktrees.\e[0m"
        echo "Usage: gwcleanup [branch]"
        echo "Deletion uses --force after confirmation."
        return 0
        ;;
      *)
        if [[ "$1" == -* ]]; then
          echo "\e[1;31m✗ Unknown option: $1\e[0m"
          echo "Usage: gwcleanup [branch]"
          return 1
        fi
        if [[ -n "$branch_filter" ]]; then
          echo "\e[1;31m✗ Too many arguments.\e[0m"
          echo "Usage: gwcleanup [branch]"
          return 1
        fi
        branch_filter="$1"
        ;;
    esac
    shift
  done

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "\e[1;31m✗ Not inside a git repository.\e[0m"
    return 1
  fi

  local current_worktree
  current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)

  local -a lines candidate_paths candidate_branches candidate_dates selected_paths
  local record_path="" record_branch="" line
  lines=("${(@f)$(git worktree list --porcelain)}")

  {
    for line in "${lines[@]}" ""; do
      if [[ "$line" == worktree\ * ]]; then
        if [[ -n "$record_path" ]]; then
          local normalized_branch="${record_branch#refs/heads/}"
          [[ -z "$normalized_branch" ]] && normalized_branch="detached"
          if [[ "${record_path:A}" != "${current_worktree:A}" ]] && { [[ -z "$branch_filter" ]] || [[ "$normalized_branch" == "$branch_filter" ]]; }; then
            local last_commit_date
            last_commit_date=$(git -C "$record_path" log -1 --date=format:'%Y-%m-%d %H:%M' --format='%cd' 2>/dev/null)
            [[ -z "$last_commit_date" ]] && last_commit_date="unknown"
            candidate_paths+=("$record_path")
            candidate_branches+=("$normalized_branch")
            candidate_dates+=("$last_commit_date")
          fi
        fi
        record_path="${line#worktree }"
        record_branch=""
        continue
      fi

      if [[ -z "$line" ]]; then
        if [[ -n "$record_path" ]]; then
          local normalized_branch="${record_branch#refs/heads/}"
          [[ -z "$normalized_branch" ]] && normalized_branch="detached"
          if [[ "${record_path:A}" != "${current_worktree:A}" ]] && { [[ -z "$branch_filter" ]] || [[ "$normalized_branch" == "$branch_filter" ]]; }; then
            local last_commit_date
            last_commit_date=$(git -C "$record_path" log -1 --date=format:'%Y-%m-%d %H:%M' --format='%cd' 2>/dev/null)
            [[ -z "$last_commit_date" ]] && last_commit_date="unknown"
            candidate_paths+=("$record_path")
            candidate_branches+=("$normalized_branch")
            candidate_dates+=("$last_commit_date")
          fi
        fi
        record_path=""
        record_branch=""
        continue
      fi

      if [[ "$line" == branch\ * ]]; then
        record_branch="${line#branch }"
      fi
    done
  } 2>/dev/null

  if (( ${#candidate_paths[@]} == 0 )); then
    if [[ -n "$branch_filter" ]]; then
      echo "\e[1;33mNo removable worktrees found for branch '$branch_filter'.\e[0m"
    else
      echo "\e[1;33mNo removable worktrees found.\e[0m"
    fi
    return 0
  fi

  if command -v fzf >/dev/null 2>&1; then
    local -a picker_rows picked_rows
    local idx
    for (( idx=1; idx<=${#candidate_paths[@]}; idx++ )); do
      picker_rows+=("$idx"$'\t'"${candidate_dates[$idx]}"$'\t'"${candidate_branches[$idx]}"$'\t'"${candidate_paths[$idx]}")
    done

    picked_rows=("${(@f)$(printf '%s\n' "${picker_rows[@]}" | fzf --multi --delimiter=$'\t' --with-nth=1,2,3 --prompt='gwcleanup > ' --header='number | last_commit_date | branch (TAB to select, ENTER to confirm)')}")

    if (( ${#picked_rows[@]} == 0 )); then
      echo "\e[1;33mCancelled.\e[0m"
      return 0
    fi

    for line in "${picked_rows[@]}"; do
      local selected_idx="${line%%$'\t'*}"
      if [[ "$selected_idx" == <-> ]] && (( selected_idx >= 1 && selected_idx <= ${#candidate_paths[@]} )); then
        selected_paths+=("${candidate_paths[$selected_idx]}")
      fi
    done
  else
    echo "\e[1;36mAvailable worktrees:\e[0m"
    local idx
    for (( idx=1; idx<=${#candidate_paths[@]}; idx++ )); do
      printf "%2d) %-16s %-24s\n" "$idx" "${candidate_dates[$idx]}" "${candidate_branches[$idx]}"
    done

    local selection
    read "selection?Enter worktree numbers to delete (comma-separated): "
    if [[ -z "$selection" ]]; then
      echo "\e[1;33mCancelled.\e[0m"
      return 0
    fi

    local -a parts
    parts=("${(@s:,:)selection}")
    local part
    for part in "${parts[@]}"; do
      local trimmed="${part//[[:space:]]/}"
      if [[ "$trimmed" != <-> ]]; then
        continue
      fi
      if (( trimmed >= 1 && trimmed <= ${#candidate_paths[@]} )); then
        selected_paths+=("${candidate_paths[$trimmed]}")
      fi
    done
  fi

  if (( ${#selected_paths[@]} == 0 )); then
    echo "\e[1;33mNo valid worktrees selected.\e[0m"
    return 0
  fi

  typeset -A seen_paths
  local -a unique_paths
  local selected_path
  for selected_path in "${selected_paths[@]}"; do
    if [[ -z "${seen_paths[$selected_path]}" ]]; then
      seen_paths[$selected_path]=1
      unique_paths+=("$selected_path")
    fi
  done
  selected_paths=("${unique_paths[@]}")

  echo "\e[1;33mWorktrees selected for deletion:\e[0m"
  printf "  %s\n" "${selected_paths[@]}"

  local confirm
  read "confirm?Delete selected worktrees? [y/N]: "
  if [[ "$confirm:l" != "y" && "$confirm:l" != "yes" ]]; then
    echo "\e[1;33mCancelled.\e[0m"
    return 0
  fi

  local removed_count=0 failed_count=0
  for selected_path in "${selected_paths[@]}"; do
    echo "\e[1;36m⟳ Removing $selected_path\e[0m"
    git worktree remove --force "$selected_path"

    if [[ $? -ne 0 ]]; then
      ((failed_count++))
      continue
    fi

    # git worktree remove usually deletes the directory too; this ensures
    # leftover files are removed if the folder still exists for any reason.
    if [[ -d "$selected_path" ]]; then
      rm -rf "$selected_path"
    fi

    ((removed_count++))
  done

  git worktree prune >/dev/null 2>&1

  if (( failed_count > 0 )); then
    echo "\e[1;31m✗ Removed $removed_count worktree(s), failed to remove $failed_count.\e[0m"
    return 1
  fi

  echo "\e[1;32m✓ Removed $removed_count worktree(s).\e[0m"
}

# Create a worktree, copy env files, and install dependencies
function gwcreate() {
  if [[ -z "$1" ]]; then
    echo "\e[1;33mCreates a worktree for a new branch, copies env files, and installs dependencies.\e[0m"
    echo "Usage: gwcreate <branch-name>"
    return 1
  fi

  local branch="$1"
  local source_dir="$PWD"

  # Create worktree as sibling directory
  echo "\e[1;36m⟳ Creating worktree for branch: $branch\e[0m"
  if ! git worktree add -b "$branch" "../$branch" 2>/dev/null; then
    # Branch might already exist, try without -b
    if ! git worktree add "../$branch" "$branch" 2>/dev/null; then
      echo "\e[1;31m✗ Failed to create worktree. Branch may already have a worktree.\e[0m"
      return 1
    fi
  fi

  cd "../$branch" || return 1

  # Copy env files from source worktree
  local env_files=("$source_dir"/.env*)
  if [[ -e "${env_files[1]}" ]]; then
    echo "\e[1;36m📋 Copying env files from source worktree\e[0m"
    cp "$source_dir"/.env* . 2>/dev/null
  fi

  # Auto-detect package manager and install dependencies
  if [[ -f "pnpm-lock.yaml" ]]; then
    echo "\e[1;36m📦 Installing dependencies with pnpm\e[0m"
    pnpm install
  elif [[ -f "bun.lockb" || -f "bun.lock" ]]; then
    echo "\e[1;36m📦 Installing dependencies with bun\e[0m"
    bun install
  elif [[ -f "yarn.lock" ]]; then
    echo "\e[1;36m📦 Installing dependencies with yarn\e[0m"
    yarn install
  elif [[ -f "package-lock.json" ]]; then
    echo "\e[1;36m📦 Installing dependencies with npm\e[0m"
    npm install
  elif [[ -f "Gemfile.lock" ]]; then
    echo "\e[1;36m📦 Installing dependencies with bundler\e[0m"
    bundle install
  elif [[ -f "requirements.txt" ]]; then
    echo "\e[1;36m📦 Installing dependencies with pip\e[0m"
    pip install -r requirements.txt
  elif [[ -f "pyproject.toml" ]]; then
    echo "\e[1;36m📦 Installing dependencies with pip\e[0m"
    pip install -e .
  elif [[ -f "go.mod" ]]; then
    echo "\e[1;36m📦 Installing dependencies with go\e[0m"
    go mod download
  elif [[ -f "Cargo.toml" ]]; then
    echo "\e[1;36m📦 Installing dependencies with cargo\e[0m"
    cargo fetch
  elif [[ -f "composer.json" ]]; then
    echo "\e[1;36m📦 Installing dependencies with composer\e[0m"
    composer install
  fi

  # Ensure git hooks are initialized in the worktree.
  # Some projects guard their prepare script with [ -d .git ] which fails in
  # worktrees where .git is a file, not a directory. Run husky explicitly to
  # guarantee hooks are set up.
  if [[ -d ".husky" ]] && ! [[ -d ".husky/_" ]]; then
    echo "\e[1;36m🪝 Initializing git hooks (husky)\e[0m"
    npx husky 2>/dev/null
  fi

  echo "\e[1;32m✓ Worktree ready at ../$branch\e[0m"
}

# Update current branch with the repo's default branch
function gup() {
  local remote=${1:-origin}
  local default_branch=$(git remote show "$remote" 2>/dev/null | sed -n 's/.*HEAD branch: //p')
  if [[ -z "$default_branch" ]]; then
    echo "\e[1;31m✗ Could not detect default branch for remote '$remote'\e[0m"
    return 1
  fi
  echo "\e[1;36m⟳ Updating $(git symbolic-ref --short HEAD) with $remote/$default_branch\e[0m"
  git fetch "$remote" "$default_branch" && git merge FETCH_HEAD
  echo "\e[1;32m🌿 Branch is fresh and up to date!\e[0m"
}
