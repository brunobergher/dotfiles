#!/usr/bin/env ruby

# Usage
# square PHOTO_DIR IMAGE_SIZE

dir = ARGV[0]
res = ARGV[1].to_i

if !dir || !res
  puts "\e[32mUsage: square PHOTO_DIR IMAGE_SIZE\e[m"
  exit
end

unless Dir.exists?("#{dir}/output")
  Dir.mkdir("#{dir}/output")
end

n = 1
Dir.glob("#{dir}/*.jpg").each do |f|
  source = "#{dir}/photo-#{n}.jpg"
  target = "#{dir}/output/photo-#{n}.jpg"
  command = "convert #{source} -gravity center -background white -extent #{res}x#{res} #{target}"
  system command
  n += 1
end
