#!/usr/bin/env ruby
# encoding: UTF-8

if ARGV[0].nil?
  puts "Extracts amplitude information from audio files to CSV file."
  puts "Output format is: time,left_channel,right_channel,combined,average"
  puts "\e[32mUsage: extract FILE DESTINATION\e[m"
  exit
end

input = ARGV[0]
output = ARGV[1]
basename = File.basename(input, ".*")
id = Time.now.to_i
tmp = "/tmp/extract-#{id}.dat"

samples = []

puts "Extracting sample data..."
system "sox #{input} #{tmp}"

puts "Restructuring..."
max = 0
File.open tmp do |file|
  file.each_line do |line|
    unless line[0] == ";"
      vals = line.split(" ").map(&:to_f)
      max = [max, vals[1].abs, vals[2].abs].max
      samples << vals
    end
  end
end

ratio = 1/max
if ratio.to_i != 1
  puts "Max amplitude is #{max}, normalizing..."
  sample = samples.map do |sample|
    sample[1] = (sample[1] * ratio).to_f.round(3)
    sample[2] = (sample[2] * ratio).to_f.round(3)
    sample[3] = [sample[1], sample[2]].max
    sample[4] = sample[3]
    sample
  end
end

puts "Saving output (#{samples.size} samples)..."
samples.map! { |s| s.join(",") }
File.open output, "w" do |file|
  file.write "time,left,right,combined,average\n"
  file.write samples.join("\n")
end

puts "Cleaning up..."
File.unlink tmp

puts "Done: #{output}"
