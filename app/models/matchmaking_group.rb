class MatchmakingGroup < ApplicationRecord
  validate :name_not_in_config
  validates :name, uniqueness: true

  def active?
    is_active
  end

  def active
    is_active
  end

  def active=(value)
    self.is_active = value
  end

  def channel
    slack_channel_name
  end

  def channel=(value)
    self.slack_channel_name = value
  end

  def size
    target_size
  end

  def size=(value)
    self.target_size = value
  end

  private

  def name_not_in_config
    if Rails.application.config.x.matchmaking.to_h.key?(name.intern)
      errors.add(:name, "cannot be the same as a key in the matchmaking config")
    end
  end
end
