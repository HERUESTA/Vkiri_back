class VideoLiver < ApplicationRecord
  belongs_to :video
  belongs_to :liver

  validates :video_id, uniqueness: { scope: :liver_id, message: "この動画にはすでに同じライバーが関連付けられています" }
end
