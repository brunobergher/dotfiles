# ============================================
# Git Configuration
# ============================================

# Git aliases are handled in aliases/git.zsh
# This file is for git config settings

# Set default branch name for new repositories
git config --global init.defaultBranch main

# Better diff algorithm
git config --global diff.algorithm histogram

# Use colors in git output
git config --global color.ui auto

# Store credentials (macOS keychain)
git config --global credential.helper osxkeychain

# Pull strategy (rebase to keep history clean)
git config --global pull.rebase true

# Enable auto-correct for mistyped commands
git config --global help.autocorrect 20