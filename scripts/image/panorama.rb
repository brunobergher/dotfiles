#!/usr/bin/env ruby

# Usage
# panorama PHOTO_DIR SIZE

dir = ARGV[0]
res = ARGV[1].to_i
temp_dir = "-panorama-temp"

if !dir || !res
  puts "\e[32mUsage: panorama PHOTO_DIR SIZE\e[m"
  exit
end

unless Dir.exists?("#{dir}/#{temp_dir}")
  Dir.mkdir("#{dir}/#{temp_dir}")
end

Dir.glob("#{dir}/*.jpg").each do |source|
  basename = File.basename(source.split("/")[1], ".jpg")

  temp = "#{dir}/#{temp_dir}/#{basename}.jpg"
  target_l = "#{dir}/panorama-#{basename}-left.jpg"
  target_r = "#{dir}/panorama-#{basename}-right.jpg"

  msg = "Creating panorama for #{basename}.jpg..."

  # Scale image up to full width + overlap and crop to max size
  command = ""
  command << "convert #{source} -resize #{res*2}x#{res}^ -gravity center -crop #{res*2}x#{res}+0+0 -gravity center +repage #{temp}"

  # Crop left image to res, position and save
  command << ";\n"
  command << "convert #{temp} -crop #{res}x#{res}+0+0 -gravity west +repage #{target_l}"

  # Crop right image to res, position and save
  command << ";\n"
  command << "convert #{temp} -crop #{res}x#{res}+#{res}+0 -gravity east +repage #{target_r}"

  # Delete tempfile
  command << ";\n"
  command << "rm #{temp}"

  # Run commands
  puts msg
  # puts command
  system command
end