#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
# Run "./add-to-playlist.rb tmp/playlist.json tmp/tracks.json tmp/cookie.txt tmp/added-tracks.json"
# Arguments:
# 1) file name with playlist info (see `export-playlist.rb`).
# 2) file name with tracks list.
# 3) file name with cookies value.
# 4) file name to save result.

require_relative "src/cli"
require_relative "src/playlist"

class AddToPlaylist < CLI
  def initialize(playlist_file_name, tracks_file_name, cookie_file_name, output_file_name)
    @file_name = output_file_name
    @playlist = Playlist.new(playlist_file_name, cookie_file_name)
    @tracks = JSON.parse(File.read(tracks_file_name))

    raise_if_not_writable_file(@file_name)
  end

  def call
    logger = create_logger("log")
    add_tracks = @playlist.select_new(@tracks)

    File.write(@file_name, JSON.pretty_generate(add_tracks))
    @playlist.add_tracks(logger, add_tracks)
  end
end

AddToPlaylist.new(*ARGV).call
