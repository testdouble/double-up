class HistoricalMatch < ApplicationRecord
  validates :matched_on, :grouping, presence: true
  validate :at_least_two_members

  private

  def at_least_two_members
    if !members.is_a?(Array) || members.size < 2
      errors.add(:members, "must include multiple members")
    end
  end
end
