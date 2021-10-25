module Matchmaking
  class DeterminesMatches
    def initialize(config: nil)
      @config = config || Rails.application.config.x.matchmaking
    end

    def call(grouping:, participants:)
      min_match_size = @config.send(grouping.intern).size
      max_group_count = participants.size / min_match_size
      # the extra iteration handles overflow when the number of participants
      # does not divide evenly
      iterations = min_match_size + (participants.size % min_match_size)
      determined_matches = []
      unmatched_participants = participants

      while iterations > 0
        (0...max_group_count).each do |group_ix|
          return determined_matches if unmatched_participants.empty?

          if determined_matches[group_ix].nil?
            # add the first member to the match when it hasn't been started
            chosen = unmatched_participants.sample
            determined_matches[group_ix] = Match.new(grouping, [chosen.id])
            unmatched_participants = unmatched_participants.reject { |p| p.id == chosen.id }
          else
            # add remaining members to the match
            current_match = determined_matches[group_ix]

            all_candidates_by_score = current_match.members.map { |member|
              participants.find { |p| p.id == member }
                .match_candidates.group_by(&:score).sort_by { |k, v| k }.to_h
            }.each_with_object({}) do |candidates_by_score, memo|
              candidates_by_score.each do |score, candidates|
                memo[score] = [] if memo[score].nil?
                memo[score].push(candidates.map(&:id))
              end

              memo
            end

            all_previously_eligible_candidates = []
            chosen = nil
            all_candidates_by_score.each do |_, candidates_for_score|
              next if candidates_for_score.empty?

              # candidate has to be unmatched AND be best option between current members
              starting_candidates = candidates_for_score.first.union(all_previously_eligible_candidates).compact
              threshold_candidates = candidates_for_score.drop(1)
                .reduce(starting_candidates) { |memo, candidates| memo.intersection(candidates) }
                .intersection(unmatched_participants.map(&:id))

              if (selected = threshold_candidates.sample)
                chosen = selected
                break
              end

              all_previously_eligible_candidates += candidates_for_score.flatten.compact
            end

            if chosen.nil? && (chosen = all_previously_eligible_candidates.sample).nil?
              raise "something went terribly terribly wrong"
            end

            determined_matches[group_ix] = Match.new(
              grouping,
              current_match.members.union([chosen]).sort
            )
            unmatched_participants = unmatched_participants.reject { |p| p.id == chosen }
          end
        end

        iterations -= 1
      end

      determined_matches
    end
  end
end
