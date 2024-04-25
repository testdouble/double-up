class ProtractedMatch < ApplicationRecord
  belongs_to :historical_match

  validates :historical_match, presence: true
  validates :completed_by, :completed_at, presence: true, if: -> { completed_at.present? || completed_by.present? }

  def complete!(completed_by)
    update!(completed_by: completed_by, completed_at: Time.zone.now)
  end

  def protract!(protracted_by)
    update!(last_protracted_by: protracted_by)
  end
end
