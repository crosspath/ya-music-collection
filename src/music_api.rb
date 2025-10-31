# frozen_string_literal: true

require "json"

class MusicAPI
  def initialize(connection, logger = nil)
    @connection = connection
    @logger = logger
  end

  def add_like_to_track(user_id, track_id, album_id)
    url = "/users/#{user_id}/likes/tracks/add?track-id=#{track_id}%3A#{album_id}"
    response = @connection.post_form(url, {})
    raise_on_error(response, "Cannot add like to track. Please update cookies!")

    JSON.parse(response.body)
  end

  def add_tracks(user_id, playlist_kind, revision, tracks)
    # {"id":"id","albumId":album_id},...
    diff_tracks = tracks.map { |x| "%7B%22id%22%3A%22#{x["id"]}%22%2C%22albumId%22%3A#{x["album_id"]}%7D" }.join(",")
    # [{"op":"insert","at":0,"tracks":[diff_tracks]}]
    diff = "%5B%7B%22op%22%3A%22insert%22%2C%22at%22%3A0%2C%22tracks%22%3A%5B#{diff_tracks}%5D%7D%5D"

    url = "/users/#{user_id}/playlists/#{playlist_kind}/change-relative?diff=#{diff}&revision=#{revision}"
    response = @connection.post_form(url, {})
    raise_on_error(response, "Cannot add tracks to playlist. Please update cookies or playlist!")

    JSON.parse(response.body)
  end

  def get_playlist(id)
    response = @connection.get("/playlist/#{id}?resumeStream=false&richTracks=false")
    raise_on_error(response, "Cannot receive playlist info. Please update cookies!")

    JSON.parse(response.body)
  end

  def get_tracks(items)
    track_ids = items.map { |x| "#{x["id"]}:#{x["album_id"]}" }
    request_body =
      {"trackIds" => track_ids, "removeDuplicates" => "false", "withProgress" => "true"}
    response = @connection.post_form("/tracks", request_body)
    raise_on_error(response, "Cannot receive tracks list.")

    JSON.parse(response.body)
  end

  def remove_tracks(user_id, playlist_kind, playlist_id, revision, from_index, to_index)
    puts "#{from_index}...#{to_index}"

    # [{"op":"delete","from":from_index,"to":to_index}]
    diff = "%5B%7B%22op%22%3A%22delete%22%2C%22from%22%3A#{from_index}%2C%22to%22%3A#{to_index}%7D%5D"
    url = "/users/#{user_id}/playlists/#{playlist_kind}/change-relative?diff=#{diff}&revision=#{revision}"
    playlist_url = "https://music.yandex.ru/playlists/#{playlist_id}"
    response = @connection.post_form(url, {}, {"X-Retpath-Y" => playlist_url})
    raise_on_error(response, "Cannot remove tracks from playlist. Please update cookies or playlist!")

    JSON.parse(response.body)
  end

  private

  def raise_on_error(response, message)
    return if response.code.to_i < 400

    @logger&.error(response.body)
    raise(message)
  end
end
