# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:/usr/local/bin:$PATH"

function parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != *"nothing to commit, working tree clean"* ]] && echo "*"
}

function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}