#!/usr/bin/env ruby

# Usage
# panorama PHOTO_DIR IMAGE_SIZE OVERLAP

dir = ARGV[0]
res = ARGV[1].to_i
overlap = (ARGV[2] || 1.01).to_f

if !dir || !res
  puts "\e[32mUsage: panorama PHOTO_DIR IMAGE_SIZE OVERLAP\e[m"
  exit
end

Dir.glob("#{dir}*-pano.jpg").each do |f|
  source = "#{f}"
  basename = File.basename(f, ".jpg")

  temp = "#{dir}output/-temp-#{basename}.png"
  target_l = "#{dir}output/#{basename}-left.jpg"
  target_r = "#{dir}output/#{basename}-right.jpg"

  full = ((res + res) * overlap).to_i
  half = (res * overlap).to_i

  msg = "Creating panorama for #{basename}.jpg..."

  # Scale image up to full width + overlap and crop to max size
  command = ""
  command << "convert #{source} -resize #{full}x#{res}^ -gravity center -crop #{res*2}x#{res}+0+0 -gravity center +repage #{temp}"

  # Crop left image to res, position and save
  command << ";\n"
  command << "convert #{temp} -crop #{half}x#{res}+0+0 -gravity west +repage #{target_l}"

  # Crop right image to res, position and save
  command << ";\n"
  command << "convert #{temp} -crop #{half}x#{res}+#{res+res-half}+0 -gravity east +repage #{target_r}"

  # Delete tempfile
  command << ";\n"
  command << "rm #{temp}"

  # Run commands
  puts msg
  # puts command
  system command
end