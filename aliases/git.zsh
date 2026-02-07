alias gad="git add"
alias gal="git add . && git add -u && echo -e \"\033[42m Added all changes: \033[40m\" && gst"
alias gam="git commit --amend"
alias gbr="git branch"
alias gcl="git clean -fd"
alias gco="git checkout"
alias gcm="git commit -m"
alias gdf="git diff"
alias glo="git log"
alias gpl='echo "\e[1;36m↓ Pulling origin $(git symbolic-ref --short HEAD) \e[0m";git fetch origin && git merge --no-edit origin/"$(git symbolic-ref --short HEAD)"'
alias gps='echo "\e[1;36m↑ Pushing origin $(git symbolic-ref --short HEAD) \e[0m";git push origin "$(git symbolic-ref --short HEAD)"'
alias gst="git status -s"
alias gwa="git worktree add"
alias gwr="git worktree remove"
alias gwl="git worktree list"
alias gwrm="$HOME/dotfiles/scripts/worktree-cleanup.sh"
alias gup="git fetch origin && git merge origin/main"

git config --global user.name "Bruno Bergher"
git config --global user.email me@brunobergher.com