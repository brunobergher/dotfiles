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


# Default ruby
source /usr/local/share/chruby/chruby.sh

# .ruby-version
. /usr/local/opt/chruby/share/chruby/chruby.sh
. /usr/local/opt/chruby/share/chruby/auto.sh

# Global git config
git config --global user.name "Bruno Bergher"
git config --global user.email "me@brunobergher.com"

# Case insensitive completion
# As per https://gist.github.com/nhibberd/9d78576aab943cdb0f6c
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'