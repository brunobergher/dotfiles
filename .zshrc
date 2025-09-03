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


#########################################################
# Beep when finishing long-running commands
#########################################################
preexec() {
    timer=$(date +%s)
    # Store the current process group to detect manual interruption
    command_pgid=$$
}

precmd() {
    if [ $timer ]; then
        now=$(date +%s)
        elapsed=$(($now-$timer))
        exit_code=$?
        
        if [[ $elapsed -gt 2 ]]; then
            # Only play sound if command wasn't manually interrupted
            # Exit codes 130 (SIGINT/Ctrl+C) and 129 (SIGHUP) indicate manual interruption
            if [[ $exit_code -ne 130 && $exit_code -ne 129 ]]; then
                if [[ $exit_code -eq 0 ]]; then
                    # Success sound - run in subshell to suppress job control messages
                    (afplay --rate 2 /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &)
                else
                    # Error sound - run in subshell to suppress job control messages
                    (afplay --rate 2 /System/Library/Sounds/Basso.aiff >/dev/null 2>&1 &)
                fi
            fi
        fi
        
        unset timer
        unset command_pgid
    fi
}