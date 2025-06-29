namespace :youtube do
  desc "Fetch videos for a specific channel"
  task :fetch_videos, [ :channel_name ] => :environment do |task, args|
    channel_name = args[:channel_name]

    if channel_name.blank?
      puts "Usage: rails youtube:fetch_videos[channel_name]"
      puts "Example: rails youtube:fetch_videos['ぶいすぽっ！']"
      exit 1
    end

    puts "Fetching videos for channel: #{channel_name}"
    YoutubeVideoFetchJob.perform_later(channel_name)
    puts "Job enqueued successfully"
  end

  desc "Fetch videos for multiple channels"
  task fetch_multiple_channels: :environment do
    channels = [
      "ぶいすぽっ！",
      "VSPO!",
      "一ノ瀬うるは",
      "藍沢エマ",
      "八雲べに"
    ]

    channels.each do |channel_name|
      puts "Enqueuing job for: #{channel_name}"
      YoutubeVideoFetchJob.perform_later(channel_name)
    end

    puts "All jobs enqueued successfully"
  end

  desc "Fetch videos immediately (for testing)"
  task :fetch_videos_now, [ :channel_name ] => :environment do |task, args|
    channel_name = args[:channel_name]

    if channel_name.blank?
      puts "Usage: rails youtube:fetch_videos_now[channel_name]"
      puts "Example: rails youtube:fetch_videos_now['ぶいすぽっ！']"
      exit 1
    end

    puts "Fetching videos immediately for channel: #{channel_name}"
    result = YoutubeVideoFetchJob.perform_now(channel_name)
    puts "Result: #{result}"
  end
end
