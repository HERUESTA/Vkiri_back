class Liver < ApplicationRecord
  has_many :video_livers, dependent: :destroy
  has_many :videos, through: :video_livers
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :display_name, length: { maximum: 255 }
  validates :channel_id, uniqueness: true, allow_blank: true
  validates :channel_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :avatar_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
end
