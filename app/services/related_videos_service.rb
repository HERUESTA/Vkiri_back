class RelatedVideosService
  def initialize(current_video, limit: 10)
    @current_video = current_video
    @limit = limit
  end

  def call
    current_liver_ids = @current_video.livers.pluck(:id)
    
    available_livers = Liver.where.not(display_name: [nil, ""])
                           .where.not(id: current_liver_ids)
                           .order("RANDOM()")
                           .limit(5)
    
    related_videos = []
    available_livers.each do |liver|
      videos = liver.videos.order(published_at: :desc).limit(3)
      related_videos.concat(videos.to_a)
      break if related_videos.size >= @limit
    end
    
    related_videos.first(@limit)
  end
end