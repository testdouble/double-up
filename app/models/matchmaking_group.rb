class MatchmakingGroup < ApplicationRecord
  SIZE_STRATEGIES = {
    exact_size: "exact_size",
    flexible_size: "flexible_size"
  }.freeze
  DEFAULT_SIZE_STRATEGY = SIZE_STRATEGIES[:flexible_size]

  validate :name_not_in_config
  validates :name, uniqueness: true

  alias_attribute :active?, :is_active
  alias_attribute :slack_channel, :slack_channel_name

  def self.name_exists?(name)
    Rails.application.config.x.matchmaking.has_group?(name) || exists?(name: name)
  end

  def size_strategy
    @strategy || DEFAULT_SIZE_STRATEGY
  end

  def size_strategy=(strategy)
    @strategy = strategy if SIZE_STRATEGIES.value?(strategy)
  end

  def flexible_size?
    size_strategy == SIZE_STRATEGIES[:flexible_size]
  end

  def exact_size?
    size_strategy == SIZE_STRATEGIES[:exact_size]
  end

  def accepted_decisions
    Array.wrap(@accepted_decisions)
  end

  def accepted_decisions=(decisions)
    @accepted_decisions = Array.wrap(decisions).uniq.reject { |d| MatchDecision::AVAILABLE_DECISIONS.exclude?(d) }
  end

  private

  def name_not_in_config
    if Rails.application.config.x.matchmaking.has_group?(name)
      errors.add(:name, "cannot be the same as a key in the matchmaking config")
    end
  end
end
