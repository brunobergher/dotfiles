function roo-worktree() {
  echo "Have you merged main in?"
  echo ""

  # Check if a branch name was provided
  if [ -z "$1" ]; then
    echo "Creates a worktree for the given branch and switches to it."
    echo "Usage: roo-worktree <new-branch-name>"
    return 1
  fi

  local branch=$1
  local current_dir_name=${PWD##*/}

  # Check if the current directory is named "main"
  if [ "$current_dir_name" != "main" ]; then
    echo "Not in main, make sure to be in the directory for the main brnach."
    return 1
  fi

  # If in "main", create the git worktree
  echo "Creating new worktree and branch: $branch"
  git worktree add -b "$branch" "../$branch"

  echo "Switching to ../$branch"
  cd "../$branch" || return
}

function roo-env() {
  # Get the current directory path
  current_path=$(pwd)
  val=""

  # Check if the path contains "roo-ext" or "roo-cloud"
  if [[ "$current_path" == *"roo-ext"* ]]; then
    val="roo-ext"
  elif [[ "$current_path" == *"roo-cloud"* ]]; then
    val="roo-cloud"
  else
    echo "Not in a valid directory."
    return 1
  fi

  # If a match is found, copy the files
  if [ -n "$val" ]; then
    echo "Coping env files for: $val"
    cp ~/dev/roo-env/$val/.* . > /dev/null 2>&1
    pnpm install
    echo "Done."
  fi
}

function roo-branch() {
# Check if a branch name was provided
  if [ -z "$1" ]; then
    echo "Creates a worktree for the given branch, switches to it and gets it ready to go."
    echo "Usage: roo-worktree <new-branch-name>"
    return 1
  fi

  local branch=$1
  roo-worktree "$branch"
  git pull origin "$branch"
  roo-env
}

function roo-main() {
  # Get the current directory
  current_path=$(pwd)

  # Check if the path contains "roo-ext" or "roo-cloud"
  if [[ "$current_path" == *"roo-ext"* ]]; then
    val="roo-ext"
  elif [[ "$current_path" == *"roo-cloud"* ]]; then
    val="roo-cloud"
  else
    echo "Not in a valid directory."
    return 1
  fi

  cd ~/dev/$val/main
  echo "Switched to main in $val"
}