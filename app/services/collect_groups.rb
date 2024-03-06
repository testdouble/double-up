class CollectGroups
  def initialize
    @config = Rails.application.config.x.matchmaking
  end

  def call
    extra_groups = MatchmakingGroup.all
    @config.groups + extra_groups
  end
end
