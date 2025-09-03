# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,zsh_prompt,exports,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Aliases
source ~/dotfiles/aliases/git.sh
source ~/dotfiles/aliases/ls.sh
source ~/dotfiles/aliases/maintenance.sh
source ~/dotfiles/aliases/meta.sh
source ~/dotfiles/aliases/network.sh
source ~/dotfiles/aliases/servers.sh
source ~/dotfiles/aliases/scripts.sh
source ~/dotfiles/aliases/shortcuts.sh

# chruby and .ruby-version
source "${HOMEBREW_PREFIX}/opt/chruby/share/chruby/chruby.sh"
source "${HOMEBREW_PREFIX}/opt/chruby/share/chruby/auto.sh"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Global git config
git config --global core.editor "code"

# Beep when finishing long-running commandspreexec() {
preexec() {
    timer=$(date +%s)
}

precmd() {
    if [ $timer ]; then
        now=$(date +%s)
        elapsed=$(($now-$timer))
        
        if [[ $elapsed -gt 10 ]]; then
            if [[ $? -eq 0 ]]; then
                afplay /System/Library/Sounds/Glass.aiff & 
            else
                afplay /System/Library/Sounds/Basso.aiff &
            fi
        fi
        
        unset timer
    fi
}

# Auto-switch Node.js version based on .nvmrc or .node-version files
autoload_nvm() {
  local node_version=""
  
  # Check for .nvmrc first, then .node-version
  if [[ -f ".nvmrc" ]]; then
    node_version=$(cat .nvmrc)
    echo "📁 Found .nvmrc specifying Node.js version: $node_version"
  elif [[ -f ".node-version" ]]; then
    node_version=$(cat .node-version)
    echo "📁 Found .node-version specifying Node.js version: $node_version"
  else
    return
  fi
  
  # Check if nvm is available
  if ! command -v nvm &> /dev/null; then
    echo "⚠️  nvm not found - please ensure nvm is properly installed and sourced"
    return
  fi
  
  # Get current Node.js version
  local current_version=$(nvm current 2>/dev/null)
  
  # Clean up version strings for comparison (remove 'v' prefix if present)
  local clean_target_version=${node_version#v}
  local clean_current_version=${current_version#v}
  
  # Switch to the specified version if it's different from current
  if [[ "$clean_current_version" != "$clean_target_version" ]]; then
    echo "🔄 Switching from Node.js $current_version to $node_version"
    nvm use "$node_version"
  else
    echo "✅ Already using Node.js $current_version"
  fi
}

# Hook the function to directory changes
autoload -U add-zsh-hook
add-zsh-hook chpwd autoload_nvm

# Also run when the shell starts (in case you're already in a directory with a version file)
autoload_nvm