# frozen_string_literal: true

require_relative "connection"
require_relative "music_api"

class Playlist
  def self.diff(tracks_list, another_tracks_list)
    track_ids = another_tracks_list.map { |x| x["id"] }.uniq

    tracks_list.reject { |x| track_ids.include?(x["id"]) }
  end

  def self.matching(tracks_list, another_tracks_list)
    track_ids = another_tracks_list.map { |x| x["id"] }.uniq

    tracks_list.select { |x| track_ids.include?(x["id"]) }
  end

  def initialize(playlist_file_name, cookie_file_name)
    @playlist = JSON.parse(File.read(playlist_file_name))
    @cookie = File.read(cookie_file_name).strip
  end

  def add_tracks(logger, tracks)
    connection = Connection.new(@cookie)
    api = MusicAPI.new(connection, logger)
    playlist_kind = @playlist["kind"]
    playlist_id = @playlist["playlistUuid"]
    revision = @playlist["revision"]
    user_id = @playlist["uid"]

    puts "Add tracks to #{playlist_id}"

    tracks.reverse.each_slice(4) do |portion|
      body = api.add_tracks(user_id, playlist_kind, revision, portion.reverse)
      revision = body["revision"]
    end
  ensure
    connection&.finish
  end

  def fetch_duplicate_tracks
    track_ids_and_indexes = {}

    @playlist["tracks"].each_with_index do |track, index|
      id = track["id"]
      track_ids_and_indexes[id] ||= []
      track_ids_and_indexes[id] << index
    end

    duplicate_track_indexes =
      track_ids_and_indexes.filter_map { |(_, v)| v[1..-1] if v.size > 1 }.flatten
    duplicate_tracks = @playlist["tracks"].fetch_values(*duplicate_track_indexes)

    duplicate_tracks.empty? ? raise("Cannot find duplicate tracks!") : duplicate_tracks
  end

  def fetch_unavailable_tracks
    unavailable_tracks = @playlist["tracks"].reject { |track| track["available"] }

    unavailable_tracks.empty? ? raise("Cannot find unavailable tracks!") : unavailable_tracks
  end

  def remove_tracks(logger, indexes)
    connection = Connection.new(@cookie)
    api = MusicAPI.new(connection, logger)
    playlist_kind = @playlist["kind"]
    playlist_id = @playlist["playlistUuid"]
    revision = @playlist["revision"]
    user_id = @playlist["uid"]

    puts "Remove tracks from #{playlist_id}"

    collect_ranges(indexes.reverse).each do |(from_index, to_index)|
      body = api.remove_tracks(user_id, playlist_kind, playlist_id, revision, from_index, to_index)
      revision = body["revision"]
    end
  ensure
    connection&.finish
  end

  def select_matching(tracks)
    Playlist.matching(@playlist["tracks"], tracks)
  end

  def select_new(tracks)
    Playlist.diff(tracks, @playlist["tracks"])
  end

  private

  def collect_ranges(indexes)
    ranges = []
    first_index = indexes.shift # Last selected track in this playlist.
    current_range = [first_index, first_index + 1]

    indexes.each do |x|
      if x + 1 == current_range[0]
        current_range[0] = x
      else
        ranges << current_range
        current_range = [x, x + 1]
      end
    end

    ranges << current_range

    ranges
  end
end
