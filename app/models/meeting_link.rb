class MeetingLink < ApplicationRecord
  belongs_to :user

  validates :link_text, :link_url, presence: true
end