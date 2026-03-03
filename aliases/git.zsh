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