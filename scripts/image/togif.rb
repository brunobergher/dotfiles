#!/usr/bin/env ruby

# Usage
# togif OUTPUT FPS PATTERN

if ARGV[0].nil? || ARGV[1].nil?
  puts "\e[32mUsage: togif OUTPUT FPS PATTERN RESIZE\e[m"
  puts "\e[32mPATTERN   In escaped shell pattern format(eg: \"\%4d.png)\e[m"
  puts "\e[32mRESIZE    ImagMmgick geometry format (eg: 600x600)\e[m"
  exit
end

######################################################################

output = ARGV[0]
fps = ARGV[1].to_f
pattern = ARGV[2] || '%4d.png'
delay = 100/fps
resize = nil
resize_msg = nil

unless ARGV[3].nil?
  resize = "-resize #{ARGV[3]}"
  resize_msg = "(while resizing to #{ARGV[3]})"
end

cmd = "convert -delay #{delay} #{resize} #{pattern} #{output}"

puts "To convert frames into #{output} #{resize_msg} at #{fps} fps..."
puts "Use this command:"
puts cmd
system cmd