#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: bounce FILE\e[m"
  exit
end

######################################################################

input = ARGV[0]
temp_1 = "_temp_bounce_1.mts"
temp_2 = "_temp_bounce_2.mts"
output = File.basename(ARGV[0], ".*") + "-bounce" + File.extname(ARGV[0])


# Create list
list = "_list_for_#{File.basename(ARGV[0], ".*")}.txt"
File.write(list, "file '#{temp_1}'\nfile '#{temp_2}'")

# Convert original and create bounded
puts "Bouncing #{input}..."
cmd = "ffmpeg -i #{input} -q 0 #{temp_1}"
system cmd
cmd = "ffmpeg -i #{temp_1} -q 0 -vf reverse #{temp_2}"
system cmd

# Merge outputs
cmd = "ffmpeg -f concat -i #{list} -c copy #{output}"
system cmd

# Cleanup
File.delete(list)
File.delete(temp_1)
File.delete(temp_2)

puts "Created #{output}."