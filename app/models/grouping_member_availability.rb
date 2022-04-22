class GroupingMemberAvailability < ApplicationRecord
  enum availability: {
    available: 0,
    unavailable: 1
  }

  validates :grouping, :member_id, presence: true
end
