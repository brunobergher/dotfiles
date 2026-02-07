# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive types
extract() {
  if [ -f $1 ]; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick find
qfind() {
  find . -name "*$1*"
}
