class User < ApplicationRecord
  has_many :calendar_links

  validates :slack_user_id, presence: true
end
