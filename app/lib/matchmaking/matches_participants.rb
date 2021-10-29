module Matchmaking
  class MatchesParticipants
    def initialize(config: nil)
      @builds_participants = BuildsParticipants.new
      @determines_matches = DeterminesMatches.new(config: config)
    end

    def call(grouping:, participant_ids:)
      return [] if participant_ids.size < 2

      @determines_matches.call(
        grouping: grouping,
        participants: @builds_participants.call(participant_ids)
      )
    end
  end
end
