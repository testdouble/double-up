module Matchmaking
  class DeterminesMatches
    def initialize(config: nil)
      @config = config || Rails.application.config.x.matchmaking
      @unmatched_participants = []
      @determined_matches = []
    end

    def call(grouping:, participants:)
      reset!(grouping, participants)

      min_match_size = @config.send(grouping.intern).size
      max_group_count = participants.size / min_match_size
      # the extra iteration handles overflow when the number of participants
      # does not divide evenly
      iterations = min_match_size + (participants.size % min_match_size)

      while iterations > 0
        (0...max_group_count).each do |group_ix|
          return @determined_matches if any_unmatched_participants?

          if match_determined?(group_ix)
            # add the first member to the match when it hasn't been started
            chosen = choose_candidate(@unmatched_participants)
            determine_match!(group_ix, Match.new(grouping: grouping, members: [chosen.id]))
            mark_participant_as_matched!(chosen.id)
          else
            # add remaining members to the match
            current_match = current_match(group_ix)

            # maybe try extracting again?
            all_previously_eligible_candidates = []
            chosen = nil
            all_candidates_by_score(participants, current_match).each do |_, candidates_for_score|
              next if candidates_for_score.empty?

              # candidate has to be unmatched AND be best option between current members
              threshold_candidates = candidates_in_common(candidates_for_score, all_previously_eligible_candidates)

              if (selected = choose_candidate(threshold_candidates))
                chosen = selected
                break
              end

              all_previously_eligible_candidates += candidates_for_score.flatten.compact
            end

            if chosen.nil? && (chosen = choose_candidate(all_previously_eligible_candidates)).nil?
              raise "something went terribly terribly wrong"
            end

            determine_match!(group_ix, Match.new(
              grouping: grouping,
              members: current_match.members.union([chosen]).sort
            ))
            mark_participant_as_matched!(chosen)
          end
        end

        iterations -= 1
      end

      @determined_matches
    end

    private

    def reset!(grouping, participants)
      @grouping = grouping
      @unmatched_participants = participants
      @determined_matches = []
    end

    def any_unmatched_participants?
      @unmatched_participants.empty?
    end

    def mark_participant_as_matched!(participant)
      @unmatched_participants = @unmatched_participants.reject { |p| p.id == participant }
    end

    def match_determined?(group_index)
      @determined_matches[group_index].nil?
    end

    def determine_match!(group_index, match)
      @determined_matches[group_index] = match
    end

    def current_match(group_index)
      @determined_matches[group_index]
    end

    def choose_candidate(eligible_candidates)
      eligible_candidates.sample
    end

    def all_candidates_by_score(participants, current_match)
      # The goal of this method may not be as clear as to _why_ it needs to
      # happen the way it is. Functionally, it builds up hash where the key
      # is the score and the value is a multi-dimensional list of candidates.
      current_match.members.map { |member|
        participants.find { |p| p.id == member }
          .match_candidates.group_by(&:score).sort_by { |k, v| k }.to_h
      }.each_with_object({}) do |candidates_by_score, memo|
        candidates_by_score.each do |score, candidates|
          memo[score] = [] if memo[score].nil?
          memo[score].push(candidates.map(&:id))
        end

        memo
      end
    end

    def candidates_in_common(candidates_per_participant, all_previously_eligible_candidates)
      starting_candidates = candidates_per_participant.first
        .union(all_previously_eligible_candidates).compact

      candidates_per_participant.drop(1)
        .reduce(starting_candidates) { |memo, candidates| memo.intersection(candidates) }
        .intersection(@unmatched_participants.map(&:id))
    end
  end
end