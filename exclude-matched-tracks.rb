#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
# Run "./exclude-matched-tracks.rb tmp/playlist.json tmp/playlist-fav.json tmp/cookie.txt tmp/matched-tracks.json"
# Arguments:
# 1) file name with first playlist info (see `export-playlist.rb`).
# 2) file name with second playlist info.
# 3) file name with cookies value.
# 4) file name to save result (tracks from first playlist that exist in second playlist).

require_relative "src/cli"
require_relative "src/playlist"

class ExcludeMatchedTracks < CLI
  def initialize(first_playlist_file_name, second_playlist_file_name, cookie_file_name, output_file_name)
    @cookie = File.read(cookie_file_name).strip
    @file_name = output_file_name
    @playlist = Playlist.new(first_playlist_file_name, cookie_file_name)
    @another_playlist = JSON.parse(File.read(second_playlist_file_name))

    raise_if_not_writable_file(@file_name)
  end

  def call
    logger = create_logger("log")
    matched_tracks = @playlist.select_matching(@another_playlist["tracks"])

    File.write(@file_name, JSON.pretty_generate(matched_tracks))
    @playlist.remove_tracks(logger, matched_tracks.map { |x| x["index"] }.sort)
  end
end

ExcludeMatchedTracks.new(*ARGV).call
