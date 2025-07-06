class YoutubeVideoFetchJob < ApplicationJob
  queue_as :default

  retry_on YoutubeApiError, wait: 10.minutes, attempts: 3 do |job, exception|
    Rails.logger.info "YoutubeAPIでエラーが発生しました。リトライします。 #{job.executions} リトライ回数: #{exception.message}"
  end

  retry_on StandardError, wait: 10.minutes, attempts: 3 do |job, exception|
    Rails.logger.info "一般的なエラーが発生しました。リトライ回数: #{job.executions} #{exception.message}"
  end

  def perform(channel_name)
    Rails.logger.info "YoutubeAPIのチャンネル情報取得を開始します: #{channel_name} at #{Time.current}"

    processor = VideoDataProcessorService.new
    result = processor.process_videos_by_channel_name(channel_name)

    Rails.logger.info "YoutubeAPIのチャンネル情報取得が完了しました: #{channel_name}. " \
                     "Videos: #{result[:videos_count]}, " \
                     "Liver created: #{result[:liver_created]}"

    result
  rescue YoutubeApiError => e
    Rails.logger.warn "YoutubeAPIエラーが発生しました: #{e.message} (Status: #{e.status_code})"

    raise e unless e.status_code == 200
  rescue => e
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
