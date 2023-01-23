class CalendarLink < ApplicationRecord
  belongs_to :user

  validates :link_name, :link_url, presence: true
end
