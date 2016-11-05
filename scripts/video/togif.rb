#!/usr/bin/env ruby

# Usage
# togif FILE WIDTH FPS

if ARGV[0].nil?
  puts "\e[32mUsage: togif FILE WIDTH FPS\e[m"
  exit
end

######################################################################

require File.dirname(__FILE__) + "/../_util/nice_size.rb"

def convert(file, width, fps)
  output = File.basename(file, ".*") + ".gif"

  puts "Converting #{file} into #{output} at #{width} pixels wide and #{fps} fps..."

  palette = "/tmp/togif-temp-palette.png"
  filters = "fps=#{fps},scale=#{width}:-1:flags=lanczos"

  File.unlink(palette) if File.exists?(palette)

  system "ffmpeg -v error -i #{file} -vf \"#{filters},palettegen\" -y #{palette}"
  system "ffmpeg -v error -i #{file} -i #{palette} -lavfi \"#{filters} [x]; [x][1:v] paletteuse\" -y #{output}"

  size_original = File.size(file).to_f
  size_new = File.size(output).to_f

  puts "Created #{output}: #{nice_size(size_new)} (original #{nice_size(size_original)})"
end

convert ARGV[0], ARGV[1] || 400, ARGV[2] || 20