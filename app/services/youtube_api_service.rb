class YoutubeApiService
  BASE_URL = "https://www.googleapis.com"

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :url_encoded
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
      faraday.options.timeout = 30
      faraday.options.open_timeout = 10
    end
    @api_key = ENV["YOUTUBE_API_KEY"]
    
    Rails.logger.debug "YouTube API Service initialized with API key: #{@api_key.present? ? 'present' : 'missing'}"
  end

  def get_channel_id_by_name(channel_name)
    Rails.logger.debug "Getting channel ID for: #{channel_name}"
    
    response = @connection.get("/youtube/v3/search") do |req|
      req.params["key"] = @api_key
      req.params["part"] = "snippet"
      req.params["q"] = channel_name
      req.params["type"] = "channel"
      req.params["maxResults"] = 1
    end

    Rails.logger.debug "Request URL: #{response.env.url}"
    data = handle_api_response(response)
    return nil if data.empty?

    channel_id = data.first.dig("id", "channelId")
    Rails.logger.debug "Found channel ID: #{channel_id}"
    channel_id
  end

  def get_videos_by_channel_id(channel_id, max_results: 50)
    Rails.logger.debug "Getting videos for channel ID: #{channel_id}"
    
    response = @connection.get("/youtube/v3/search") do |req|
      req.params["key"] = @api_key
      req.params["part"] = "snippet"
      req.params["channelId"] = channel_id
      req.params["type"] = "video"
      req.params["maxResults"] = max_results
      req.params["order"] = "date"
      # 時間制限を削除してすべての動画を取得
      # req.params["publishedAfter"] = 30.days.ago.iso8601
    end

    Rails.logger.debug "Video search URL: #{response.env.url}"
    videos = handle_api_response(response)
    Rails.logger.debug "Found #{videos.size} videos"
    videos
  end

  def get_video_details(video_ids)
    return [] if video_ids.empty?
    
    Rails.logger.debug "Getting video details for #{video_ids.size} videos: #{video_ids.join(', ')}"

    response = @connection.get("/youtube/v3/videos") do |req|
      req.params["key"] = @api_key
      req.params["part"] = "snippet,statistics,contentDetails"
      req.params["id"] = video_ids.join(",")
    end

    Rails.logger.debug "Video details URL: #{response.env.url}"
    details = handle_api_response(response)
    Rails.logger.debug "Retrieved details for #{details.size} videos"
    details
  end

  def get_channel_details(channel_id)
    response = @connection.get("/youtube/v3/channels") do |req|
      req.params["key"] = @api_key
      req.params["part"] = "snippet"
      req.params["id"] = channel_id
    end

    data = handle_api_response(response)
    data.first if data.any?
  end

  private

  def handle_api_response(response)
    Rails.logger.debug "API Response Status: #{response.status}"
    Rails.logger.debug "API Response Body Type: #{response.body.class}"
    Rails.logger.debug "API Response Body: #{response.body.inspect}"
    
    unless response.success?
      error_message = response.body.dig("error", "message") || "Unknown error"
      raise YoutubeApiError.new("youtubeAPIレスポンスの取得で失敗しました #{error_message}", response.status)
    end

    # レスポンスが文字列の場合、JSONパースを試行
    parsed_body = response.body
    if parsed_body.is_a?(String)
      begin
        parsed_body = JSON.parse(parsed_body)
        Rails.logger.debug "Successfully parsed JSON string"
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse JSON response: #{e.message}"
        raise YoutubeApiError.new("Invalid JSON response from YouTube API", response.status)
      end
    end

    parsed_body.dig("items") || []
  end
end

class YoutubeApiError < StandardError
  attr_reader :status_code

  def initialize(message, status_code = nil)
    super(message)
    @status_code = status_code
  end
end
