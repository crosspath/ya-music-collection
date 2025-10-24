# frozen_string_literal: true

require "net/http"
require "random/formatter"

class Connection
  def initialize(cookie)
    @cookie = cookie
    @session_id = cookie.match(/Session_id=.+?\|(\d+)/)&.[](1)
    raise("Cannot find session_id in cookies!") if @session_id.nil?

    @http = Net::HTTP.start(CONNECTION_PARAMS[:domain], **CONNECTION_PARAMS[:options])
  end

  def finish
    @http.finish
    @http = nil
  end

  def get(url)
    puts "Request #{url}"

    @http.get(url, headers)
  end

  def post_form(url, data, extra_headers = {})
    puts "Post #{url}"

    request = Net::HTTP::Post.new(url)
    request.delete("Accept-Encoding")
    request.form_data = data
    headers.each { |k, v| request[k] = v }
    extra_headers.each { |k, v| request[k] = v }

    @http.request(request)
  end

  private

  CONNECTION_PARAMS = {
    domain: "api.music.yandex.ru",
    options: {
      open_timeout: 3, # seconds
      read_timeout: 3, # seconds
      ssl_timeout: 3, # seconds
      use_ssl: true,
    },
  }.freeze

  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0",
    "Accept" => "*/*",
    "Accept-Language" => "ru",
    # "Accept-Encoding" => "gzip, deflate, br, zstd",
    "Referer" => "https://music.yandex.ru/",
    "x-yandex-music-client" => "YandexMusicWebNext/1.0.0",
    "x-yandex-music-without-invocation-info" => "1",
    "X-Requested-With" => "XMLHttpRequest",
    "X-Retpath-Y" => "https://music.yandex.ru/collection",
    "Origin" => "https://music.yandex.ru",
    "DNT" => "1",
    "Sec-GPC" => "1",
    "Sec-Fetch-Dest" => "empty",
    "Sec-Fetch-Mode" => "cors",
    "Sec-Fetch-Site" => "same-site",
    "Connection" => "keep-alive",
    "Priority" => "u=4",
    "TE" => "trailers",
  }.freeze

  private_constant :CONNECTION_PARAMS, :HEADERS

  def headers
    @headers ||= HEADERS.merge(
      "x-request-id" => Random.uuid,
      "x-yandex-music-multi-auth-user-id" => @session_id,
      "Cookie" => @cookie,
    )
  end
end
