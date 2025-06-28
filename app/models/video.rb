class Video < ApplicationRecord
  has_many :video_livers, dependent: :destroy
  has_many :livers, through: :video_livers
  
  validates :youtube_id, uniqueness: true, allow_blank: true
  validates :title, length: { maximum: 255 }
  validates :duration_seconds, numericality: { greater_than: 0, allow_blank: true }
  validates :view_count, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
  validates :thumbnail_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  
  scope :published_after, ->(date) { where("published_at > ?", date) }
  scope :by_liver, ->(liver_id) { joins(:video_livers).where(video_livers: { liver_id: liver_id }) }
end
