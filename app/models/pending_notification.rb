class PendingNotification < ApplicationRecord
  belongs_to :historical_match

  validates :strategy, inclusion: {in: %w[slack email], message: "%{value} is not a valid notification strategy"}
  validates :historical_match, presence: true
end
