class AddIndexesToTables < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :email, name: "idx_users_email"
    add_index :users, :username, name: "idx_users_username"
    
    add_index :livers, :channel_id, name: "idx_livers_channel_id"
    
    add_index :videos, :youtube_id, name: "idx_videos_youtube_id"
    add_index :videos, :published_at, name: "idx_videos_published_at"
    
    add_index :video_livers, :video_id, name: "idx_video_livers_video_id"
    add_index :video_livers, :liver_id, name: "idx_video_livers_liver_id"
  end
end
