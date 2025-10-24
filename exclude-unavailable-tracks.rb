#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
# Run "./exclude-unavailable-tracks.rb tmp/playlist.json tmp/cookie.txt tmp/unavailable-tracks.json"
# Arguments:
# 1) file name with playlist info (see `export-playlist.rb`).
# 2) file name with cookies value.
# 3) file name to save result.

require_relative "src/cli"
require_relative "src/playlist"

class ExcludeUnavailableTracks < CLI
  def initialize(playlist_file_name, cookie_file_name, output_file_name)
    @file_name = output_file_name
    @playlist = Playlist.new(playlist_file_name, cookie_file_name)

    raise_if_not_writable_file(@file_name)
  end

  def call
    logger = create_logger("log")
    unavailable_tracks = @playlist.fetch_unavailable_tracks

    File.write(@file_name, JSON.pretty_generate(unavailable_tracks))
    @playlist.remove_tracks(logger, unavailable_tracks.map { |x| x["index"] })
  end
end

ExcludeUnavailableTracks.new(*ARGV).call
