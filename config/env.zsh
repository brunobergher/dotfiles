# ============================================
# Environment Variables
# ============================================

# Default editor
export EDITOR="code --wait"
export VISUAL="code --wait"

# Other useful environment variables
export PAGER="less"
export LESS="-R"  # Color support in less

# Add your home bin to PATH if it exists
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
