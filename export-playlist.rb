#!/usr/bin/env ruby
# frozen_string_literal: true

# Usage:
# Run "./export-playlist.rb 12345678-90ab-cdef-1234-567890abcdef tmp/cookie.txt tmp/playlist.json"
# Arguments:
# 1) playlist id (known as "playlistUuid" in response).
# 2) file name with cookies value.
# 3) file name to save result.

require_relative "src/cli"
require_relative "src/connection"
require_relative "src/music_api"
require_relative "src/presenter"

class ExportPlaylist < CLI
  TRACKS_LIMIT = 20

  private_constant :TRACKS_LIMIT

  def initialize(playlist_id, cookie_file_name, output_file_name)
    @playlist_id = playlist_id
    @cookie = File.read(cookie_file_name).strip
    @file_name = output_file_name

    raise_if_not_writable_file(@file_name)
  end

  def call
    connection = Connection.new(@cookie)
    logger = create_logger("log")

    api = MusicAPI.new(connection, logger)
    playlist_body = Presenter.playlist(api.get_playlist(@playlist_id))

    playlist_body["tracks"].each_slice(TRACKS_LIMIT) do |tracks|
      tracks_body = Presenter.tracks(api.get_tracks(tracks))

      tracks.each { |x| x.merge!(tracks_body[x["id"]] || {}) }
    end

    File.write(@file_name, JSON.pretty_generate(playlist_body))
  ensure
    connection&.finish
  end
end

ExportPlaylist.new(*ARGV).call
