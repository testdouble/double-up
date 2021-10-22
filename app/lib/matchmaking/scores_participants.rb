module Matchmaking
  class ScoresParticipants
    def call(participants:)
      participants.map { |participant| adjust_scores(participant) }
    end

    private

    def adjust_scores(participant)
      adjusted_scores = participant.scored_matches.map do |potential_match|
        all_historical_matches = participant.grouped_historical_matches.values.flatten

        match_count = all_historical_matches.count { |historical_match|
          historical_match.matches.include?(potential_match.person)
        }

        if match_count.positive?
          ScoredMatch.new(potential_match.person, potential_match.score + match_count)
        else
          potential_match
        end
      end

      Participant.new(participant.person, adjusted_scores, participant.grouped_historical_matches)
    end
  end
end
