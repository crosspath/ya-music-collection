#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
# Run "./playlist-diff.rb tmp/playlist-1.json tmp/playlist-2.json tmp/diff.json"
# Arguments:
# 1) file name with first playlist info (see `export-playlist.rb`).
# 2) file name with second playlist info.
# 3) file name to save result (tracks from first playlist minus tracks from second playlist).

require_relative "src/cli"
require_relative "src/playlist"

class PlaylistDiff < CLI
  def initialize(first_playlist_file_name, second_playlist_file_name, output_file_name)
    @file_name = output_file_name
    @first_playlist = JSON.parse(File.read(first_playlist_file_name))
    @second_playlist = JSON.parse(File.read(second_playlist_file_name))

    raise_if_not_writable_file(@file_name)
  end

  def call
    result_tracks = Playlist.diff(@first_playlist["tracks"], @second_playlist["tracks"])

    File.write(@file_name, JSON.pretty_generate(result_tracks))
  end
end

PlaylistDiff.new(*ARGV).call
