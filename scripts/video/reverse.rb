#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: reverse FILE\e[m"
  exit
end

######################################################################

input = ARGV[0]
output = File.basename(ARGV[0], ".*") + "-reverse" + File.extname(ARGV[0])

puts "Reversing #{input}..."

cmd = "ffmpeg -i #{input} -vf reverse #{output}"
system cmd

puts "Created #{output}."


