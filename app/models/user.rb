class User < ApplicationRecord
  has_many :meeting_links

  validates :slack_user_id, presence: true
end
