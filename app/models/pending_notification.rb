class PendingNotification < ApplicationRecord
  belongs_to :historical_match

  validates :strategy, inclusion: {in: %w[slack email], message: "%{value} is not a valid notification strategy"}
  validates :historical_match, presence: true

  scope :for_grouping, ->(grouping) { includes(:historical_match).where(historical_match: {grouping: grouping}) }

  def use_slack?
    strategy == "slack"
  end

  def use_email?
    strategy == "email"
  end
end
