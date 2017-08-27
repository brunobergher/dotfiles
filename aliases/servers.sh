# Simple Static webserver from the current directory
alias serve=" ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 8000, :DocumentRoot => Dir.pwd).start'"
alias be="bundle exec "