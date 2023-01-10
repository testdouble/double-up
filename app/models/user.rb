class User < ApplicationRecord
  validates :slack_user_id, presence: true
end
