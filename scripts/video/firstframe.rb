#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: firstframe DIR\e[m"
  exit
end

dir = ARGV[0]
# dir = Dir.pwd if dir == "."
extensions = "mp4,mov,flv,mpg,m4k"
pattern = dir + "/*.{#{extensions}}"

puts "Extracting the first frame of videos in #{dir}..."
Dir[pattern].each do |f|
  output = File.basename(f).split(".")[0] + "-001.png"
  cmd = "ffmpeg -i #{f} -vframes 1 -f image2 #{output}"
  system cmd
end