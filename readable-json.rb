#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
# Run "./readable-json.rb tmp/p.json"

require "json"

ARGV.each do |file_name|
  puts "Read #{file_name}"
  input = File.read(file_name)
  json = JSON.pretty_generate(JSON.parse(input))
  puts "Write #{file_name}-1"
  File.write("#{file_name}-1", json)
end
