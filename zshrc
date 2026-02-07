# ============================================
# Core Configuration
# ============================================

# Path to dotfiles
export DOTFILES="$HOME/.dotfiles"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ============================================
# Load modular configs
# ============================================

# Source all alias files
for alias_file in $DOTFILES/aliases/*.zsh; do
  [ -r "$alias_file" ] && source "$alias_file"
done

# Source all function files
for function_file in $DOTFILES/functions/*.zsh; do
  [ -r "$function_file" ] && source "$function_file"
done

# Source all config files
for config_file in $DOTFILES/config/*.zsh; do
  if [ -r "$config_file" ]; then
    source "$config_file"
  fi
done

# ============================================
# Tool Initializations
# ============================================

# Homebrew (check both locations for Intel/Apple Silicon)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# zsh-autosuggestions
if [ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Starship prompt
eval "$(starship init zsh)"

# Add any other tool inits here (nvm, etc)

