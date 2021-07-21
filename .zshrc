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


# Default ruby
source "${HOMEBREW_PREFIX}/chruby/chruby.sh"

# .ruby-version
. "${HOMEBREW_PREFIX}/chruby/share/chruby/chruby.sh"
. "${HOMEBREW_PREFIX}/chruby/share/chruby/auto.sh"

# Global git config
git config --global user.name "Bruno Bergher"
git config --global user.email "me@brunobergher.com"

# Case insensitive completion
# As per https://gist.github.com/nhibberd/9d78576aab943cdb0f6c
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'