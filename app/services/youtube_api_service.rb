class YoutubeApiService
  BASE_URL = 'https://www.googleapis.com/youtube/v3'
  
  def initialize
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
      faraday.options.timeout = 30
      faraday.options.open_timeout = 10
    end
    @api_key = ENV['YOUTUBE_API_KEY']
  end

  def get_channel_id_by_name(channel_name)
    response = @connection.get('/search') do |req|
      req.params['key'] = @api_key
      req.params['part'] = 'snippet'
      req.params['q'] = channel_name
      req.params['type'] = 'channel'
      req.params['maxResults'] = 1
    end

    data = handle_api_response(response)
    return nil if data.empty?

    data.first.dig('id', 'channelId')
  end

  def get_videos_by_channel_id(channel_id, max_results: 50)
    response = @connection.get('/search') do |req|
      req.params['key'] = @api_key
      req.params['part'] = 'snippet'
      req.params['channelId'] = channel_id
      req.params['type'] = 'video'
      req.params['maxResults'] = max_results
      req.params['order'] = 'date'
      req.params['publishedAfter'] = 24.hours.ago.iso8601
    end

    handle_api_response(response)
  end

  def get_video_details(video_ids)
    return [] if video_ids.empty?

    response = @connection.get('/videos') do |req|
      req.params['key'] = @api_key
      req.params['part'] = 'snippet,statistics,contentDetails'
      req.params['id'] = video_ids.join(',')
    end

    handle_api_response(response)
  end

  def get_channel_details(channel_id)
    response = @connection.get('/channels') do |req|
      req.params['key'] = @api_key
      req.params['part'] = 'snippet'
      req.params['id'] = channel_id
    end

    data = handle_api_response(response)
    data.first if data.any?
  end

  private

  def handle_api_response(response)
    unless response.success?
      error_message = response.body.dig('error', 'message') || 'Unknown error'
      raise YoutubeApiError.new("YouTube API request failed: #{error_message}", response.status)
    end

    response.body.dig('items') || []
  end
end

class YoutubeApiError < StandardError
  attr_reader :status_code

  def initialize(message, status_code = nil)
    super(message)
    @status_code = status_code
  end
end
