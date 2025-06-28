class CreateLivers < ActiveRecord::Migration[8.0]
  def change
    create_table :livers, id: :bigint do |t|
      t.string :name, limit: 255, null: false
      t.string :display_name, limit: 255
      t.string :channel_id, limit: 255
      t.string :channel_url, limit: 255
      t.string :avatar_url, limit: 255
      
      t.timestamps
    end
  end
end
