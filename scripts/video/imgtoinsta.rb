#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: imgtoinstagram OUTPUT PATTERN\e[m"
  puts "\e[32mDefault pattern is \"\%4d.png\"\e[m"
  exit
end
output = ARGV[0] || "_output"
pattern = ARGV[1] || '%4d.png'

puts "Converting files matching #{pattern} to #{output}..."
cmd = "ffmpeg -f image2 -i \"#{pattern}\" -framerate 30 -vcodec mpeg4 -strict -2 -vb 5500k -mbd 2 -flags +mv4+aic -trellis 1 -cmp 2 -subcmp 2 #{output}.mp4"
system cmd