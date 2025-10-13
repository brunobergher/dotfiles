#!/usr/bin/env ruby
# encoding: UTF-8

if ARGV[0].nil?
  puts "Smoothes sample values extracted from audio file."
  puts "\e[32mUsage: smooth INPUT SAMPLES_FOR_AVG [OUTPUT]"
  exit
end

input = ARGV[0]
number = ARGV[1].to_i
basename = File.basename(input, ".*")
output = ARGV[2] || "#{basename}-smooth-#{number}.csv"
id = Time.now.to_i

headers = File.open(input, "r") { |file| file.first }
curr_line = 0
series = []
rows = []

def moving_average(a,ndays,precision)
  a.each_cons(ndays).map { |e| (e.reduce(&:+).to_f/ndays).round(precision) }
end

puts "Gathering values..."
File.open input do |file|
  file.each_line do |line|
    if curr_line > 0
      vals = line.split(",")
      vals.each_with_index do |v, i|
        series[i] = [] if !series[i]
        series[i] << v
      end
    end
    curr_line = curr_line + 1
  end
end

puts "Smoothing with #{number}-sample moving average..."
max = 0
series.map! do |s|
  avg = moving_average(s, number, 5)
  max = [avg.max, max].max
  s = avg
end

puts "Renormalizing..."
ratio = 1/max
series.map! do |s|
  s.map! do |r|
    r * ratio
  end
end

puts "Restructuring..."
i = 0
while i < series[0].size
  row = []
  series.each do |s|
    row << s[i]
  end
  rows << row.join(",")
  i = i + 1
end

puts "Saving #{output}..."
File.open(output, "w") do |file|
  file.write headers
  file.write rows.join("\n")
end