# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~='cd ~'
alias dev="cd ~/dev"

# Editor
alias c='code'

# Modern CLI replacements
alias ls='eza --icons'
alias ll='eza --icons -la'

# Common shortcuts
alias c='clear'
alias h='history'
alias q='exit'

# Safety nets
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# Fill what's running in a given port
killport() {
  PORT=$1
  if [ -z "$PORT" ]; then
    echo "Please specify a port number."
    return 1
  fi

  PID=$(lsof -t -i:$PORT)

  if [ -z "$PID" ]; then
    echo "No process found running on port $PORT."
  else
    echo "Killing process with PID $PID on port $PORT."
    kill -9 "$PID"
    echo "Process killed."
  fi
}