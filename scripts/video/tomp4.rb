#!/usr/bin/env ruby

# Usage
# tomp4 FILE

if ARGV[0].nil?
  puts "\e[32mUsage: tomp4 FILE\e[m"
  exit
end

######################################################################

require File.dirname(__FILE__) + "/../_util/nice_size.rb"

def convert(file)
  file = file
  output = File.basename(file, ".*") + ".mp4"

  system "ffmpeg -v error -i \"#{file}\" -vcodec h264 -acodec aac -strict -2 \"#{output}\""

  size_original = File.size(file).to_f
  size_new = File.size(output).to_f
  puts "Created #{output}: #{nice_size(size_new)} (original #{nice_size(size_original)}, #{100-(size_new/size_original*100).round}% savings)"
end

convert ARGV[0]