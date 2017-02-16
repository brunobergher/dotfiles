#!/usr/bin/env ruby

# Usage
# npm MODULES

modules = ARGV

def humanize(name)
  name = name.gsub(/[\-\_]/," ")
  name = name.split(" ").map { |w| w[0].upcase + w[1..-1] }
  name.join("")
end

if modules.size == 0
  puts "\e[32mUsage: npm module1 module2 module3 ...\e[m"
  exit
end

# Prepare npm file
if File.exists?("modules/npm.coffee")
  content = ""
else
  content = "# This file references all npm modules used by this project\n"
end

# Install modules
modules.each do |m|
  puts "Installing module #{humanize(m)}\n"
  system "npm install #{m} --silent"
  content << "\nexports.#{humanize(m)} = require \"#{m}\""
end

# Update file
File.open("modules/npm.coffee", "a") do |f|
  f << content
end

# Output
output = "{ #{modules.map { |m| humanize(m) }.join(", ") } } = require \"npm\""
puts "\nPaste this to app.coffee:"
puts "\e[32m#{output}\e[0m"