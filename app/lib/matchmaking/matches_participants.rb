module Matchmaking
  class MatchesParticipants
    def initialize
      @scores_participants = ScoresParticipants.new
    end

    def call(participants:)
      return [] if participants.size < 2

      scored_participants = @scores_participants.call(
        participants: normalize_participants(participants)
      )

      participants
    end

    private

    def normalize_participants(participants)
      participants.map do |person|
        scored_matches = (participants - [person]).map { |other_person| ScoredMatch.new(other_person, 0) }
        historical_matches = HistoricalMatch.where("'#{person}' = any(matches)").to_a.group_by { |m| m.grouping }

        Participant.new(p, scored_matches, historical_matches)
      end
    end
  end
end
