module Matchmaking
  class ScoresParticipantCandidates
    def call(participant:)
      return participant if participant.grouped_historical_matches.empty?

      all_historical_matches = participant.grouped_historical_matches.values.flatten

      candidates_with_adjusted_scores = participant.match_candidates.map do |candidate|
        candidate_matches = historical_candidate_matches(all_historical_matches, candidate)

        if (match_count = candidate_matches.count).positive?
          ScoredMatchCandidate.new(id: candidate.id, score: candidate.score + match_count)
        else
          candidate
        end
      end

      Participant.new(
        id: participant.id,
        match_candidates: candidates_with_adjusted_scores,
        grouped_historical_matches: participant.grouped_historical_matches
      )
    end

    private

    def historical_candidate_matches(historical_matches, candidate)
      historical_matches.select { |match| match.members.include?(candidate.id) }
    end
  end
end
