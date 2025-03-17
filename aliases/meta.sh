# Reload the shell (i.e. invoke as a login shell)
alias reload="exec $SHELL -l"
# Reload dotfiles (bootstrap)
alias reload!="set -- -f; source ~/dotfiles/bootstrap.sh"
# Open this
alias dotfiles="cd ~/dotfiles; code ."