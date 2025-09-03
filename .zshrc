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

# Global git config
git config --global core.editor "code"

# asdf runtime manager
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit

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