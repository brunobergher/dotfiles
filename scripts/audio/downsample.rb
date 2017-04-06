#!/usr/bin/env ruby
# encoding: UTF-8

if ARGV[0].nil?
  puts "Reduces the number of samples to the supplied number in extracted sample files"
  puts "\e[32mUsage: downsample INPUT NUMBER [OUTPUT]"
  exit
end


input = ARGV[0]
number = ARGV[1].to_i
basename = File.basename(input, ".*")
id = Time.now.to_i
output = ARGV[2] || "#{basename}-#{number}.csv"

headers = File.open(input, "r") { |file| file.first }
rows = []
curr_line = 0
orig_count = `wc -l "#{input}"`.strip.split(' ')[0].to_i - 1 # Assumes header row

puts "Reducing #{orig_count} to #{number} samples..."
slice = (orig_count/number).floor
File.open input do |file|
  file.each_line do |line|
    if curr_line != 0 && curr_line % slice == 0
      rows << line
    end
    break if rows.size >= number
    curr_line = curr_line + 1
  end
end

puts "Saving #{output}..."
File.open(output, "w") do |file|
  file.write headers
  file.write rows.join()
end

puts "Done."