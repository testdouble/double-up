module Matchmaking
  class CollectScoredParticipants
    def initialize
      @assign_score_to_candidates = AssignScoreToCandidates.new
    end

    def call(participants, group)
      participants.reduce({}) do |memo, participant|
        recent_matches = HistoricalMatch.scoreable.with_member(participant).in_grouping(group.name)
        candidates = participants.difference([participant])

        scored_candidates = @assign_score_to_candidates.call(candidates, recent_matches)

        memo.merge(participant => scored_candidates)
      end
    end
  end
end
