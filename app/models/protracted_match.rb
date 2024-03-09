class ProtractedMatch < ApplicationRecord
  belongs_to :historical_match

  validates :protracted_by, :historical_match, presence: true
  validates :completed_at, :completed_by, presence: true, if: -> { completed_by.present? || completed_at.present? }
end
