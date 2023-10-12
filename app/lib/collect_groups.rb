class CollectGroups
  def initialize(config: nil)
    @config ||= Rails.application.config.x.matchmaking
  end

  def call
  end
end
