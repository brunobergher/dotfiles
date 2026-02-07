# Work-specific configuration
# Only load on work machine

# Check if this is the roo machine (adjust the check as needed)
if [ -d "$HOME/dev/roo-env" ]; then
  # Source work functions
  [ -f "$DOTFILES/config/roo/config.zsh" ] && source "$DOTFILES/config/roo/config.zsh"
fi
