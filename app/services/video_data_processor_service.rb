class VideoDataProcessorService
  def initialize
    @youtube_service = YoutubeApiService.new
  end

  def process_videos_by_channel_name(channel_name)
    Rails.logger.info "Processing videos for channel: #{channel_name}"

    channel_id = @youtube_service.get_channel_id_by_name(channel_name)
    
    if channel_id.nil?
      Rails.logger.warn "Channel not found for name: #{channel_name}"
      return { videos_count: 0, liver_created: false }
    end

    liver = find_or_create_liver(channel_id, channel_name)

    videos = @youtube_service.get_videos_by_channel_id(channel_id)
    
    if videos.empty?
      Rails.logger.info "No videos found for channel: #{channel_name}"
      return { videos_count: 0, liver_created: liver.previously_new_record? }
    end

    video_ids = videos.map { |video| video.dig('id', 'videoId') }.compact
    detailed_videos = @youtube_service.get_video_details(video_ids)

    saved_videos = save_videos_to_database(detailed_videos, liver)

    {
      videos_count: saved_videos.size,
      liver_created: liver.previously_new_record?,
      liver_id: liver.id
    }
  end

  private

  def find_or_create_liver(channel_id, channel_name)
    liver = Liver.find_by(channel_id: channel_id)
    
    return liver if liver

    channel_details = @youtube_service.get_channel_details(channel_id)
    
    Liver.create!(
      name: channel_name,
      display_name: channel_details&.dig('snippet', 'title') || channel_name,
      channel_id: channel_id,
      channel_url: "https://www.youtube.com/channel/#{channel_id}",
      avatar_url: channel_details&.dig('snippet', 'thumbnails', 'medium', 'url')
    )
  rescue => e
    Rails.logger.error "Failed to create liver for channel #{channel_name}: #{e.message}"
    Liver.create!(
      name: channel_name,
      display_name: channel_name,
      channel_id: channel_id
    )
  end

  def save_videos_to_database(videos, liver)
    saved_videos = []

    videos.each do |video|
      existing_video = Video.find_by(youtube_id: video['id'])
      
      if existing_video
        update_existing_video(existing_video, video)
        saved_videos << existing_video
      else
        new_video = create_new_video(video)
        saved_videos << new_video if new_video
      end
    end

    saved_videos.each do |video|
      associate_video_with_liver(video, liver)
    end

    saved_videos
  end

  def create_new_video(video_data)
    Video.create!(
      youtube_id: video_data['id'],
      title: video_data.dig('snippet', 'title'),
      thumbnail_url: video_data.dig('snippet', 'thumbnails', 'medium', 'url'),
      duration_seconds: parse_duration(video_data.dig('contentDetails', 'duration')),
      view_count: video_data.dig('statistics', 'viewCount').to_i,
      uploader_name: video_data.dig('snippet', 'channelTitle'),
      uploader_channel_id: video_data.dig('snippet', 'channelId'),
      published_at: Time.parse(video_data.dig('snippet', 'publishedAt'))
    )
  rescue => e
    Rails.logger.error "Failed to create video #{video_data['id']}: #{e.message}"
    nil
  end

  def update_existing_video(existing_video, video_data)
    existing_video.update!(
      view_count: video_data.dig('statistics', 'viewCount').to_i,
      title: video_data.dig('snippet', 'title')
    )
  rescue => e
    Rails.logger.error "Failed to update video #{existing_video.youtube_id}: #{e.message}"
  end

  def associate_video_with_liver(video, liver)
    VideoLiver.find_or_create_by(
      video: video,
      liver: liver
    )
  rescue => e
    Rails.logger.error "Failed to associate video #{video.youtube_id} with liver #{liver.id}: #{e.message}"
  end

  def parse_duration(duration)
    return 0 unless duration

    iso_duration = ISO8601::Duration.new(duration)
    iso_duration.to_seconds.to_i
  rescue => e
    Rails.logger.error "Failed to parse duration #{duration}: #{e.message}"
    0
  end
end
