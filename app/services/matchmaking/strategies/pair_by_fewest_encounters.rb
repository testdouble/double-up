module Matchmaking
  module Strategies
    # This strategy pairs participants with the fewest encounters with each other. It does not
    # create groups of more than 2 participants unless there is an odd number of participants. The
    # strategy expects a hash of participants and their scores for each other participant. The
    # scores represent the number of times the participants have encountered each other. The
    # scores are used to determine the best pairings.
    #
    # Input example:
    #   {
    #    "Alice" => {"Bob" => 1, "Charlie" => 0, "Dave" => 2, "Eve" => 1},
    #    "Bob" => {"Alice" => 1, "Charlie" => 3, "Dave" => 1, "Eve" => 2},
    #    "Charlie" => {"Alice" => 0, "Bob" => 3, "Dave" => 2, "Eve" => 3},
    #    "Dave" => {"Alice" => 2, "Bob" => 1, "Charlie" => 2, "Eve" => 1},
    #    "Eve" => {"Alice" => 1, "Bob" => 2, "Charlie" => 3, "Dave" => 1}
    #   }
    #
    # Output example:
    #   [["Alice", "Charlie"], ["Bob", "Dave", "Eve"]]
    class PairByFewestEncounters
      def initialize(options = {})
        @options = options
      end

      def call(scored_participants)
        unmatched = scored_participants.dup
        matches = []

        until unmatched.empty?
          participant1 = unmatched.keys.sample
          participant2 = find_best_match(participant1, unmatched, [participant1])

          if participant2
            matches << [participant1, participant2]
            unmatched = remove_participants([participant1, participant2], unmatched)
          else
            match = find_best_match_for_last_participant(participant1, scored_participants.dup, matches)
            matches = matches.map { |pair| (pair == match) ? [pair[0], pair[1], participant1] : pair }
            unmatched = remove_participants([participant1], unmatched)
          end
        end

        matches
      end

      def allow_third_participant?
        @options.fetch(:allow_third_participant, true)
      end

      private

      def remove_participants(participants, unmatched)
        unmatched.except(*participants).map { |k, v| [k, v.except(*participants)] }.to_h
      end

      def find_best_match_for_last_participant(participant, scored_participants, matches)
        return nil unless allow_third_participant?

        matches
          .map { |match| match.map { |p| [p, scored_participants[p][participant]] } }
          .min_by { |pair| pair[0].last.abs + pair[1].last.abs }
          &.map(&:first)
      end

      def find_best_match(participant, unmatched, excluded = [])
        # Filter out participants that have already been matched with the participant which
        # necessary for situations where a third participant needs placed
        potential_matches = unmatched[participant].except(*excluded).group_by { |_, v| v }

        return nil if potential_matches.empty?

        min_score_group = potential_matches[potential_matches.keys.min]
        min_score_group.map(&:first).sample
      end
    end
  end
end
