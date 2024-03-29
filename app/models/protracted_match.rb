class ProtractedMatch < ApplicationRecord
  belongs_to :historical_match

  validates :historical_match, presence: true
  validates :completed_by, :completed_at, presence: true, if: -> { completed_at.present? || completed_by.present? }

  def complete_as!(completed_by)
    update!(completed_by: completed_by, completed_at: Time.zone.now)
  end
end
