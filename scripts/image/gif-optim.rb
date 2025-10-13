#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: gif-optim FILE COLORS\e[m"
  puts "\e[32mColors: max number of colors, default 64\e[m"
  exit
end

######################################################################

require File.dirname(__FILE__) + "/../_util/nice_size.rb"

input = ARGV[0]
colors = ARGV[1] || 64
output = File.basename(input, ".gif") + "-optim-#{colors}.gif"

puts "Optimizing #{input} with a max of #{colors} colors..."
system "gifsicle -i #{input} -O3 --colors #{colors} -o #{output}"

size_original = File.size(input).to_f
size_new = File.size(output).to_f
savings = ((size_original-size_new)/size_original).round(2)*100

puts "Created #{output}: #{nice_size(size_new)} (original #{nice_size(size_original)}, #{savings}\% savings)."