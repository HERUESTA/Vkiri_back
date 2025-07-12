class RelatedVideosService
  def initialize(current_video, limit: 10)
    @current_video = current_video
    @limit = limit
  end

  def call
    # 現在の動画を除外した関連動画を取得
    related_videos = Video.includes(:livers)
                          .where.not(id: @current_video.id)
                          .order(published_at: :desc)
                          .limit(@limit)

    related_videos.to_a
  end
end
