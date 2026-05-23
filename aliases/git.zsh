alias gad="git add"
alias gal="git add . && git add -u && echo -e \"\033[42m Added all changes: \033[40m\" && gst"
alias gam="git commit --amend"
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
  local remote="origin"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "\e[1;31m✗ Not inside a git repository.\e[0m"
    return 1
  fi

  local repo_root
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$repo_root" ]]; then
    echo "\e[1;31m✗ Could not determine repository root.\e[0m"
    return 1
  fi

  local repo_parent="${repo_root:h}"
  local repo_root_name="${repo_root:t}"
  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  local default_branch=""
  default_branch=$(git symbolic-ref --short "refs/remotes/${remote}/HEAD" 2>/dev/null)
  default_branch="${default_branch#${remote}/}"
  if [[ -z "$default_branch" ]]; then
    default_branch=$(git remote show "$remote" 2>/dev/null | sed -n 's/.*HEAD branch: //p')
  fi

  local branch_container="$repo_parent"
  local layout_mode="branch-dir"
  local layout_ok=0
  if [[ -n "$current_branch" && "$repo_root_name" == "$current_branch" ]]; then
    layout_ok=1
  elif [[ -n "$default_branch" && "$repo_root_name" == "$default_branch" ]]; then
    layout_ok=1
  elif [[ "$repo_root_name" == "main" || "$repo_root_name" == "master" || "$repo_root_name" == "develop" ]]; then
    layout_ok=1
  fi

  if (( layout_ok == 0 )); then
    echo "\e[1;31m✗ This repo is not in enforced branch-folder layout.\e[0m"
    echo "Expected to run from a branch folder like .../<repo>/main (or master/develop)."
    echo "Current repo root is: $repo_root"
    echo "Use gbrco <repo-url-or-owner/repo> to clone into the expected layout."
    return 1
  fi

  local target_dir="${branch_container}/${branch}"

  local source_dir="$repo_root"
  local default_branch_worktree=""
  if [[ -n "$default_branch" ]]; then
    local -a wt_lines
    local wt_path="" wt_branch="" wt_line
    wt_lines=("${(@f)$(git worktree list --porcelain)}")
    for wt_line in "${wt_lines[@]}" ""; do
      if [[ "$wt_line" == worktree\ * ]]; then
        wt_path="${wt_line#worktree }"
        continue
      fi
      if [[ "$wt_line" == branch\ * ]]; then
        wt_branch="${wt_line#branch refs/heads/}"
        continue
      fi
      if [[ -z "$wt_line" ]]; then
        if [[ -n "$wt_path" && "$wt_branch" == "$default_branch" ]]; then
          default_branch_worktree="$wt_path"
          break
        fi
        wt_path=""
        wt_branch=""
      fi
    done
  fi

  if [[ -n "$default_branch_worktree" ]]; then
    source_dir="$default_branch_worktree"
  fi

  if [[ -n "$default_branch" && "$current_branch" != "$default_branch" ]]; then
    if [[ -n "$default_branch_worktree" ]]; then
      echo "\e[1;36mℹ Using $default_branch_worktree ($default_branch) as setup source.\e[0m"
    else
      echo "\e[1;33m⚠ Not on $default_branch and no $default_branch worktree found; using current worktree as setup source.\e[0m"
    fi
  fi

  # Create worktree in selected layout container
  echo "\e[1;36m⟳ Creating worktree for branch: $branch\e[0m"
  echo "\e[1;36mℹ Layout: $layout_mode ($target_dir)\e[0m"
  if ! git worktree add -b "$branch" "$target_dir" 2>/dev/null; then
    # Branch might already exist, try without -b
    if ! git worktree add "$target_dir" "$branch" 2>/dev/null; then
      echo "\e[1;31m✗ Failed to create worktree. Branch may already have a worktree.\e[0m"
      return 1
    fi
  fi

  cd "$target_dir" || return 1

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

  echo "\e[1;32m✓ Worktree ready at $target_dir\e[0m"
}

# Checkout a repo into enforced branch-folder layout under ~/dev/<repo>/<default-branch>
function gbrco() {
  if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "\e[1;33mClones a repo into ~/dev/<repo>/<default-branch> and switches there.\e[0m"
    echo "Usage: gbrco <repo-url-or-owner/repo> [default-branch]"
    return 0
  fi

  local input="$1"
  local requested_branch="$2"
  local repo_url=""
  local repo_slug=""
  local repo_name=""

  if [[ "$input" == git@* || "$input" == http://* || "$input" == https://* || "$input" == ssh://* ]]; then
    repo_url="$input"
  elif [[ "$input" == */* ]]; then
    repo_url="git@github.com:${input}.git"
  else
    echo "\e[1;31m✗ Invalid repo identifier: $input\e[0m"
    echo "Use a full git URL or owner/repo."
    return 1
  fi

  repo_slug="${repo_url##*/}"
  repo_name="${repo_slug%.git}"

  if [[ -z "$repo_name" ]]; then
    echo "\e[1;31m✗ Could not determine repo name from input.\e[0m"
    return 1
  fi

  local container="$HOME/dev/$repo_name"
  local default_branch="$requested_branch"

  if [[ -z "$default_branch" ]]; then
    default_branch=$(git ls-remote --symref "$repo_url" HEAD 2>/dev/null | sed -n 's#^ref: refs/heads/\([^[:space:]]*\)[[:space:]]*HEAD#\1#p')
  fi
  [[ -z "$default_branch" ]] && default_branch="main"

  local target_dir="$container/$default_branch"

  if [[ -d "$target_dir/.git" || -f "$target_dir/.git" ]]; then
    echo "\e[1;36mℹ Existing checkout found at $target_dir\e[0m"
    cd "$target_dir" || return 1
    return 0
  fi

  if [[ -d "$container/.git" || -f "$container/.git" ]]; then
    echo "\e[1;31m✗ Found a plain clone at $container, which conflicts with enforced layout.\e[0m"
    echo "Move it to $target_dir (or reclone) before using gbr/gwcreate."
    return 1
  fi

  mkdir -p "$container" || {
    echo "\e[1;31m✗ Failed to create $container\e[0m"
    return 1
  }

  echo "\e[1;36m⟳ Cloning $repo_url into $target_dir\e[0m"
  if ! git clone --branch "$default_branch" "$repo_url" "$target_dir"; then
    echo "\e[1;31m✗ Clone failed.\e[0m"
    return 1
  fi

  cd "$target_dir" || return 1
  echo "\e[1;32m✓ Ready at $target_dir\e[0m"
}

# Create and switch to a new branch worktree
alias gbr="gwcreate"

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
