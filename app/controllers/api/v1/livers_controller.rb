class Api::V1::LiversController < ApplicationController
  before_action :set_liver, only: [ :show, :videos ]

  # GET /api/v1/livers
  def index
    @livers = Liver.order(:display_name)

    render json: {
      livers: serialize_livers(@livers)
    }
  end

  # GET /api/v1/livers/:id
  def show
    render json: { liver: serialize_liver(@liver) }
  end

  # GET /api/v1/livers/:id/videos
  def videos
    @videos = @liver.videos.includes(:livers)
                           .order(published_at: :desc)
                           .page(params[:page])
                           .per(params[:per_page] || 20)

    render json: {
      liver: serialize_liver(@liver),
      videos: serialize_videos(@videos),
      pagination: {
        current_page: @videos.current_page,
        total_pages: @videos.total_pages,
        total_count: @videos.total_count,
        per_page: @videos.limit_value
      }
    }
  end

  private

  def set_liver
    @liver = Liver.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("Liver not found")
  end

  def serialize_livers(livers)
    livers.map { |liver| serialize_liver(liver) }
  end

  def serialize_liver(liver)
    {
      id: liver.id,
      name: liver.name,
      display_name: liver.display_name,
      channel_id: liver.channel_id,
      channel_url: liver.channel_url,
      avatar_url: liver.avatar_url,
      video_count: liver.videos.count,
      created_at: liver.created_at,
      updated_at: liver.updated_at
    }
  end

  def serialize_videos(videos)
    videos.map { |video| serialize_video(video) }
  end

  def serialize_video(video)
    {
      id: video.id,
      youtube_id: video.youtube_id,
      title: video.title,
      thumbnail_url: video.thumbnail_url,
      duration_seconds: video.duration_seconds,
      duration_formatted: format_duration(video.duration_seconds),
      view_count: video.view_count,
      view_count_formatted: format_view_count(video.view_count),
      uploader_name: video.uploader_name,
      uploader_channel_id: video.uploader_channel_id,
      published_at: video.published_at,
      published_at_formatted: format_date(video.published_at),
      youtube_url: video.youtube_url,
      youtube_embed_url: video.youtube_embed_url,
      created_at: video.created_at,
      updated_at: video.updated_at
    }
  end

  def format_duration(seconds)
    return "0:00" if seconds.nil? || seconds <= 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    secs = seconds % 60

    if hours > 0
      sprintf("%d:%02d:%02d", hours, minutes, secs)
    else
      sprintf("%d:%02d", minutes, secs)
    end
  end

  def format_view_count(count)
    return "0" if count.nil? || count <= 0

    if count >= 1_000_000
      sprintf("%.1fM", count / 1_000_000.0)
    elsif count >= 1_000
      sprintf("%.1fK", count / 1_000.0)
    else
      count.to_s
    end
  end

  def format_date(date)
    return "" if date.nil?
    date.strftime("%Y年%m月%d日")
  end
end
