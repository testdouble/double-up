module Matchmaking
  class MatchParticipants
    def initialize
      @collect_scored_participants = CollectScoredParticipants.new
      @choose_strategy = ChooseStrategy.new
    end

    def call(participants, group)
      # We don't want to consider a group of 1 a match
      return [] if participants.size < 2

      scored_participants = @collect_scored_participants.call(participants, group)

      strategy = @choose_strategy.call(group)
      return [] unless strategy

      strategy.call(scored_participants)
    end
  end
end
