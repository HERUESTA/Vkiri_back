class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos, id: :bigint do |t|
      t.string :youtube_id, limit: 255
      t.string :title, limit: 255
      t.string :thumbnail_url, limit: 255
      t.integer :duration_seconds
      t.integer :view_count
      t.string :uploader_name, limit: 255
      t.string :uploader_channel_id, limit: 255
      t.datetime :published_at

      t.timestamps
    end
  end
end
