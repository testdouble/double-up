module Matchmaking
  class AssignScoreToCandidates
    def call(candidates, recent_matches)
      recent_matches = recent_matches.sort_by(&:matched_on).reverse

      # The priority is represented by a multiplier. The higher the multiplier, the lower the priority since
      # we want a candidate to be deprioritized if they have been matched with the participant recently. The
      # multiplier is only higher than 1 for the most recent 3 matches to avoid consecutive matches having
      # similar members.
      priority_multiplier = recent_matches.take(4).zip([3, 2.5, 2, 1.5]).to_h

      candidates.map do |candidate|
        candidate_matches = recent_matches.select { |match| match.members.include?(candidate) }
        multiplier = candidate_matches.map { |match| priority_multiplier[match] || 1 }.max || 1

        [candidate, candidate_matches.size * multiplier]
      end.to_h
    end
  end
end
