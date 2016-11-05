#!/usr/bin/env ruby

# Usage
# togif FILE WIDTH FPS

if ARGV[0].nil?
  puts "\e[32mUsage: togif FILE WIDTH FPS\e[m"
  exit
end

file  = ARGV[0]
width = (ARGV[1] || 400).to_i
fps   = (ARGV[2] || 20).to_i
output = File.basename(file, ".*") + ".gif"

puts "Converting #{file} into #{output} at #{width} pixels wide and #{fps} fps..."

palette = "/tmp/togif-temp-palette.png"
filters = "fps=#{fps},scale=#{width}:-1:flags=lanczos"

File.unlink(palette) if File.exists?(palette)

system "ffmpeg -v error -i #{file} -vf \"#{filters},palettegen\" -y #{palette}"
system "ffmpeg -v error -i #{file} -i #{palette} -lavfi \"#{filters} [x]; [x][1:v] paletteuse\" -y #{output}"