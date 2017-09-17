#!/usr/bin/env ruby

if ARGV[0].nil?
  puts "\e[32mUsage: fadeloop FILE FADELENGTH\e[m"
  puts "\e[32m  FADELENGTH is in seconds. Default is 1\e[m"
  exit
end

######################################################################

input = ARGV[0]
output = File.basename(ARGV[0], ".*") + "-loop.mp4"
fade = Float(ARGV[1] || 1)

puts "Creating loopable video of #{input} with #{fade}s crossfade..."

cmd_len = "ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 #{input}"
length = Float(`#{cmd_len}`)

cmd_conv = "ffmpeg -i #{input} -filter_complex \"[0]split[body][pre];[pre]trim=duration=#{fade},format=yuva420p,fade=duration=#{fade}:alpha=1,setpts=PTS+(#{length-fade-fade}/TB)[jt];[body]trim=0,setpts=PTS-STARTPTS[main];[main][jt]overlay\" #{output}"
system cmd_conv

puts "Created #{output}, #{length}s long."