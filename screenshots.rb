#!/usr/bin/env ruby
require 'shellwords'

unless defined?(Rails)
  ENV['RAILS_ENV'] = ENV['RAILS_ENV'] || 'development'
  require File.expand_path(File.dirname(__FILE__) + "/config/environment")
end

if ARGV.empty?
  puts "Run with filename: screenshots.rb film.avi";
  exit
end

screenshots_path = '/tmp/screenshots'
Dir.mkdir(screenshots_path) unless Dir.exists? screenshots_path

data = ARGV.each_with_object({}) do |anime_dir, memo|
  anime_name = anime_dir.split('/').last.gsub ' ', '_'
  puts "parsing #{anime_name}"

  files = Dir.entries("#{anime_dir}").each_with_object({}) do |anime_path, memo|
    next if anime_path.starts_with? '.'
    file_name = anime_path.split('/').last
    episode_num = TorrentsParser.extract_episodes_num(file_name).first

    memo[episode_num] ||= file_name if file_name !~ /\.ass$|\.srt$/
  end
    .select {|k,v| k == 1 || k == 2 }
    .sort_by {|k,v| k }
    .map {|k,v| v }

  memo[anime_dir] = files if files.any?
end

SCREEN_EVERY = {
  true => 17,
  false => 29
}
START_FROM = {
  true => 17,
  false => 240
}

puts "\n\nfound animes: "
ap data.keys

data.each do |anime_dir, files|
  anime_name = anime_dir.split('/').last.gsub ' ', '_'
  target_path = "#{screenshots_path}/#{anime_name}"
  Dir.mkdir(target_path) unless Dir.exists? target_path

  ap anime_name
  ap anime_dir
  ap files
  files.each_with_index do |file_name, index|
    file_path = "#{anime_dir}/#{file_name}"

    time = 0
    i = 0
    target_file = nil
    images = []

    begin
      target_file = "%s/%s_#{index}_%03d.jpg" % [target_path, anime_name, i]
      time = START_FROM[files.size == 1] + i * SCREEN_EVERY[files.size == 1]
      %x{/usr/local/bin/ffmpeg -ss #{time} -i #{Shellwords.escape file_path} -y #{Shellwords.escape target_file}}
      images << target_file if File.exists?(target_file)
      i += 1
    end while File.exists?(target_file)

    images.reverse.take(7).each {|v| File.delete v }
  end
end
