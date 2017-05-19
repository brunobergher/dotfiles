#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: imgtoinstagram PATTERN OUTPUT FPS\e[m"
  exit
end

pattern = ARGV[0] || "\%4d.png"
output = ARGV[1] || "_output.mov"
fps = ARGV[2] || 30

puts "Converting files matching #{pattern} to #{output} at #{fps}"
system "ffmpeg -loop 0 -i #{pattern} -c:v libx264 -strict -2 -r #{fps} -pix_fmt yuv420p #{output}"