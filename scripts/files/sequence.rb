#!/usr/bin/env ruby

# Usage
# sequence DIR FORMAT

if ARGV[0].nil?
  puts "\e[32mUsage: sequence DIR FORMAT\e[m"
  exit
end

dir = ARGV[0]
format = "%04d"
counter = 1

Dir.chdir(dir)
Dir.glob("*.*").each do |f|
  parts = f.to_s.split(".")
  newname = sprintf(format, counter) + "." + parts[-1]
  File.rename(f, newname)
  puts "Renamed #{f} to #{newname}"
  counter += 1
end