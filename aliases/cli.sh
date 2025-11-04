# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias dev="cd ~/dev"§

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Ring the terminal bell, and put a badge on Terminal.app’s Dock icon
# (useful when executing time-consuming commands)
alias badge="tput bel"

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