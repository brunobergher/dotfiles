# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,zsh_prompt,exports,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

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
[ -s "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh" ] && . "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh"  # This loads nvm
[ -s "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && . "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Global git config
git config --global --replace-all user.name "Bruno Bergher"
git config --global --replace-all user.email "me@brunobergher.com"   