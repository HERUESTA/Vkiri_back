class Api::V1::VideosController < ApplicationController
  before_action :set_video, only: [ :show ]

  # GET /api/v1/videos
  def index
    per_page = params[:per_page]&.to_i || 20
    current_page = params[:page]&.to_i || 1
    offset = (current_page - 1) * per_page

    @videos = Video.includes(:livers)
                   .order(published_at: :desc)
                   .limit(per_page)
                   .offset(offset)

    total_count = Video.count
    total_pages = (total_count.to_f / per_page).ceil

    render json: {
      videos: serialize_videos(@videos),
      pagination: {
        current_page: current_page,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }
  end

  # GET /api/v1/videos/:id
  def show
    render json: { video: serialize_video(@video) }
  end

  # GET /api/v1/videos/by_liver
  def by_liver
    unless params[:liver_id].present?
      return render_error("liver_id parameter is required")
    end

    per_page = params[:per_page]&.to_i || 20
    current_page = params[:page]&.to_i || 1
    offset = (current_page - 1) * per_page

    @videos = Video.joins(:video_livers)
                   .where(video_livers: { liver_id: params[:liver_id] })
                   .includes(:livers)
                   .order(published_at: :desc)
                   .limit(per_page)
                   .offset(offset)

    total_count = Video.joins(:video_livers).where(video_livers: { liver_id: params[:liver_id] }).count
    total_pages = (total_count.to_f / per_page).ceil

    render json: {
      videos: serialize_videos(@videos),
      pagination: {
        current_page: current_page,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }
  end

  private

  def set_video
    @video = Video.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("Video not found")
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
      updated_at: video.updated_at,
      livers: video.livers.map do |liver|
        {
          id: liver.id,
          name: liver.name,
          display_name: liver.display_name,
          avatar_url: liver.avatar_url,
          channel_url: liver.channel_url,
          channel_id: liver.channel_id
        }
      end
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
