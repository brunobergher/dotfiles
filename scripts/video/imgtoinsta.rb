#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: imgtoinstagram OUTPUT FPS PATTERN\e[m"
  puts "\e[32mDefault pattern is \"\%4d.png\"\e[m"
  exit
end
output = ARGV[0] || "_output"
fps = ARGV[1] || 30
pattern = ARGV[2] || '%4d.png'

puts "Converting files matching #{pattern} to #{output}..."
# cmd = "ffmpeg -f image2 -r #{fps} -i \"#{pattern}\" -vcodec mpeg4 -strict -2 -vb 20000k -mbd 2 -flags +mv4+aic -trellis 1 -cmp 2 -subcmp 2 #{output}.mp4"
# cmd = "ffmpeg -f image2 -r #{fps} -i \"#{pattern}\" -vcodec mpeg4 -c:v libx264 -vb 5000k -vf scale=1080:1080 -crf 20 #{output}.mp4"
cmd = "ffmpeg -f image2 -r #{fps} -i \"#{pattern}\" -vcodec mpeg4 -vb 3500k -vf scale=1080:1080 -strict experimental -qscale 0 #{output}.mp4"
system cmd