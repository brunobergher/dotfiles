#!/usr/bin/env ruby
# encoding: UTF-8

# Easy access to imagemagick, ffmpeg and other useful scripts
# ./scripts.rb group script
# Works best if scripts.rb is aliased

BASE = File.dirname(__FILE__)

def list
  puts "\e[32mUsage: scr group script parameter1 parameter2 ...\e[m"
  puts "Available scripts:"
  last_type = "-----"
  Dir.chdir(BASE)
  Dir.glob("*/*.rb").each do |file|
    type = file.split("/")[0]
    puts "▸ #{type}" if(type != last_type)
    puts "  ↳ #{file.gsub(".rb", "").gsub("/", "").gsub(type,"")}"
    last_type = type
  end
end

group  = ARGV[0]
script = ARGV[1]
params = ARGV[2..-1]

if !group || group == "list"
  list
  exit
end

system "ruby #{BASE}/#{group}/#{script}.rb #{params.join(' ')}"