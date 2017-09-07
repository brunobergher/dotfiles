alias be="bundle exec "
alias serve="STATIC_PORT=${1:-8000}; ruby -run -ehttpd . -p${STATIC_PORT}"