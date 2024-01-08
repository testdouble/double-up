module Matchmaking
  class MatchParticipants
    def initialize(config: nil)
      @collect_scored_participants = CollectScoredParticipants.new
      @config = config || Rails.application.config.x.matchmaking
      @choose_strategy = ChooseStrategy.new(config: @config)
    end

    def call(participants, grouping)
      # We don't want to consider a group of 1 a match
      return [] if participants.size < 2

      scored_participants = @collect_scored_participants.call(participants, grouping)

      strategy = @choose_strategy.call(grouping)

      strategy.call(scored_participants)
    end
  end
end
