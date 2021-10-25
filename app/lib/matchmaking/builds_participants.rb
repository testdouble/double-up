module Matchmaking
  class BuildsParticipants
    def initialize
      @scores_participant_candidates = ScoresParticipantCandidates.new
    end

    def call(participant_ids)
      participant_ids.map do |id|
        match_candidates = build_match_candidates(participant_ids, id)
        grouped_historical_matches = collect_historical_matches_by_grouping(id)

        @scores_participant_candidates.call(
          participant: Participant.new(id, match_candidates, grouped_historical_matches)
        )
      end
    end

    private

    def build_match_candidates(participant_ids, current_id)
      participant_ids.difference([current_id])
        .map { |other_id| ScoredMatchCandidate.new(other_id, 0) }
    end

    def collect_historical_matches_by_grouping(participant_id)
      HistoricalMatch.where("'#{participant_id}' = any(members)").to_a
        .group_by { |m| m.grouping }
    end
  end
end
