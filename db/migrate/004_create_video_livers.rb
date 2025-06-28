class CreateVideoLivers < ActiveRecord::Migration[8.0]
  def change
    create_table :video_livers, id: :bigint do |t|
      t.bigint :video_id, null: false
      t.bigint :liver_id, null: false
      t.datetime :created_at, null: false

      t.foreign_key :videos, on_delete: :cascade
      t.foreign_key :livers, on_delete: :cascade

      t.index [ :video_id, :liver_id ], unique: true, name: "unique_video_liver"
    end
  end
end
