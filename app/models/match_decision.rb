class MatchDecision < ApplicationRecord
  AVAILABLE_DECISIONS = ["protract", "complete"]

  belongs_to :historical_match

  validates :decision, :decided_by, presence: true
  validates :decision, inclusion: {in: AVAILABLE_DECISIONS}
end
