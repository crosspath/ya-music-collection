# frozen_string_literal: true

module Presenter
  extend self

  # @param body [Hash]
  # @return [Hash]
  def playlist(body)
    playlist_body = body.slice(*PLAYLIST_ATTRIBUTES)

    playlist_body["tracks"].map! do |track|
      {
        "album_id" => track["albumId"],
        "id" => track["id"],
        "index" => track["originalIndex"],
      }
    end

    playlist_body
  end

  # @param body [Array<Hash>]
  # @return [Hash<Integer, Hash>]
  def tracks(body)
    body.to_h do |track|
      res = track.slice(*TRACK_ATTRIBUTES)
      res["artists"].map! { |x| x.slice(*ARTIST_ATTRIBUTES) }
      [track["id"].to_i, res]
    end
  end

  ARTIST_ATTRIBUTES = %w[
    id
    name
    various
  ].freeze

  PLAYLIST_ATTRIBUTES = %w[
    playlistUuid
    uid
    kind
    title
    revision
    trackCount
    tracks
  ].freeze

  TRACK_ATTRIBUTES = %w[
    title
    available
    artists
    error
  ].freeze

  private_constant :ARTIST_ATTRIBUTES, :PLAYLIST_ATTRIBUTES, :TRACK_ATTRIBUTES
end
