#!/usr/bin/env ruby

# Usage
# square PHOTO_DIR

dir = ARGV[0]
res = (ARGV[1] || 3100).to_i

if !dir || !res
  puts "\e[32mUsage: square PHOTO_DIR\e[m"
  exit
end

unless Dir.exists?("#{dir}/output")
  Dir.mkdir("#{dir}/output")
end

Dir.glob("#{dir}/*.jpg").each do |source|
  dimensions = `identify -ping -format \"%[fx:w]x%[fx:h]\" #{source}`
  dimensions = dimensions.split("x").map { |d| d.to_i }
  res = dimensions.max

  target = "square-#{source.split("/")[1]}"
  command = "convert #{source} -gravity center -background white -extent #{res}x#{res} #{target}"
  system command
end