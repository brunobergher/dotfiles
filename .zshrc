# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,zsh_prompt,exports,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Aliases
source ~/dotfiles/aliases/cli.sh
source ~/dotfiles/aliases/git.sh
source ~/dotfiles/aliases/ls.sh
source ~/dotfiles/aliases/maintenance.sh
source ~/dotfiles/aliases/meta.sh
source ~/dotfiles/aliases/network.sh
source ~/dotfiles/aliases/scripts.sh
source ~/dotfiles/aliases/servers.sh
source ~/dotfiles/aliases/shortcuts.sh

# Utilities
source ~/dotfiles/utilities/roo.sh

# Global git config
git config --global core.editor "code"

# asdf runtime manager
. /opt/homebrew/opt/asdf/libexec/asdf.sh
# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit


#########################################################
# Beep when finishing long-running commands
#########################################################

# List of interactive programs that should not trigger sounds
interactive_programs=(
    "vi" "vim" "nvim" "nano" "emacs" "ed" "pico"  # editors
    "less" "more" "most" "bat"                     # pagers
    "top" "htop" "btop" "atop" "glances"           # system monitors
    "man" "info" "help"                            # documentation viewers
    "ssh" "mosh" "telnet" "ftp" "sftp"             # remote shells
    "gdb" "lldb" "pdb" "ipdb"                      # debuggers
    "irb" "pry" "python" "python3" "node" "deno"   # REPLs
    "psql" "mysql" "sqlite3" "mongo" "redis-cli"   # database clients
    "tig" "lazygit" "gitui"                        # git interfaces
    "ranger" "nnn" "lf" "mc" "vifm"                # file managers
    "tmux" "screen" "zellij"                       # terminal multiplexers
    "watch"                                        # command watchers
)

preexec() {
    timer=$(date +%s)
    # Store the current process group to detect manual interruption
    command_pgid=$$
    
    # Extract the base command (first word) from the full command
    local cmd="${1%% *}"
    # Remove any path and get just the command name
    cmd="${cmd##*/}"
    
    # Check if it's an interactive program
    is_interactive=false
    for prog in "${interactive_programs[@]}"; do
        if [[ "$cmd" == "$prog" ]]; then
            is_interactive=true
            break
        fi
    done
}

precmd() {
    if [ $timer ]; then
        now=$(date +%s)
        elapsed=$(($now-$timer))
        exit_code=$?
        threshold=10
        
        # Only play sound for non-interactive commands that took more than 2 seconds
        if [[ $elapsed -gt threshold && "$is_interactive" != "true" ]]; then
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
        unset is_interactive
    fi
}