class YoutubeVideoFetchJob < ApplicationJob
  queue_as :default

  retry_on YoutubeApiError, wait: 10.minutes, attempts: 3 do |job, exception|
    Rails.logger.error "YouTube API error after #{job.executions} attempts: #{exception.message}"
  end

  retry_on StandardError, wait: 10.minutes, attempts: 3 do |job, exception|
    Rails.logger.error "General error after #{job.executions} attempts: #{exception.message}"
  end

  def perform(channel_name)
    Rails.logger.info "Starting YouTube video fetch job for channel: #{channel_name} at #{Time.current}"

    processor = VideoDataProcessorService.new
    result = processor.process_videos_by_channel_name(channel_name)

    Rails.logger.info "YouTube video fetch job completed for #{channel_name}. " \
                     "Videos: #{result[:videos_count]}, " \
                     "Liver created: #{result[:liver_created]}"

    result
  rescue YoutubeApiError => e
    Rails.logger.error "YouTube API error for channel #{channel_name}: #{e.message} (Status: #{e.status_code})"

    raise e unless e.status_code == 200
  rescue => e
    Rails.logger.error "YouTube video fetch job failed for channel #{channel_name}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
