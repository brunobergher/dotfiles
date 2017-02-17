#!/usr/bin/env ruby

# Usage
# togif OUTPUT FPS PATTERN

if ARGV[0].nil? || ARGV[1].nil?
  puts "\e[32mUsage: togif OUTPUT FPS PATTERN\e[m"
  exit
end

######################################################################

files = ARGV[2..-1]
output = ARGV[0]
fps = ARGV[1].to_f
delay = 100/fps

puts "Converting #{files.size} frames into #{output} at #{fps} fps..."
system "convert -delay #{delay} #{files.join(" ")} #{output}"
