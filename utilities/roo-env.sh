function roo-worktree() {
  echo "Have you merged main in?"
  echo ""
  
  # Check if a branch name was provided
  if [ -z "$1" ]; then
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
    cp ~/dev/roo-env/$val/.* .
    cp ~/dev/roo-env/$val/* .
    pnpm install
    echo "Done."
  fi
}


function roo-branch() {
# Check if a branch name was provided
  if [ -z "$1" ]; then
    echo "Usage: roo-worktree <new-branch-name>"
    return 1
  fi

  local branch=$1
  roo-worktree "$branch"
  roo-env
}