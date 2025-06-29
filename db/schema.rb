# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 5) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "livers", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "display_name", limit: 255
    t.string "channel_id", limit: 255
    t.string "channel_url", limit: 255
    t.string "avatar_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "idx_livers_channel_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255
    t.string "encrypted_password", limit: 255
    t.string "username", limit: 255
    t.string "display_name", limit: 255
    t.boolean "email_verified", default: false
    t.datetime "email_verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "idx_users_email"
    t.index ["username"], name: "idx_users_username"
  end

  create_table "video_livers", force: :cascade do |t|
    t.bigint "video_id", null: false
    t.bigint "liver_id", null: false
    t.datetime "created_at", null: false
    t.index ["liver_id"], name: "idx_video_livers_liver_id"
    t.index ["video_id", "liver_id"], name: "unique_video_liver", unique: true
    t.index ["video_id"], name: "idx_video_livers_video_id"
  end

  create_table "videos", force: :cascade do |t|
    t.string "youtube_id", limit: 255
    t.string "title", limit: 255
    t.string "thumbnail_url", limit: 255
    t.integer "duration_seconds"
    t.integer "view_count"
    t.string "uploader_name", limit: 255
    t.string "uploader_channel_id", limit: 255
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["published_at"], name: "idx_videos_published_at"
    t.index ["youtube_id"], name: "idx_videos_youtube_id"
  end

  add_foreign_key "video_livers", "livers", on_delete: :cascade
  add_foreign_key "video_livers", "videos", on_delete: :cascade
end
