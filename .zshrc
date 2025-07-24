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

=======
[ -s "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh" ] && . "${HOMEBREW_PREFIX}/opt/nvm/nvm.sh"  # This loads nvm
[ -s "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && . "${HOMEBREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Global git config
git config --global user.name "Bruno Bergher"
git config --global user.email "me@brunobergher.com"
>>>>>>> 713d7b6 (NVM)
