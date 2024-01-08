require "test_helper"

module Matchmaking
  module Strategies
    class PairByFewestEncountersTest < Minitest::Test
      def setup
        srand(98765)

        @subject = PairByFewestEncounters
        @scored_participants = {
          "Frodo" => {"Pippin" => 0, "Merry" => 1, "Sam" => 2, "Gandalf" => 1},
          "Sam" => {"Frodo" => 2, "Pippin" => 1, "Merry" => 0, "Gandalf" => 0},
          "Pippin" => {"Frodo" => 0, "Merry" => 2, "Sam" => 1, "Gandalf" => 3},
          "Merry" => {"Frodo" => 1, "Pippin" => 2, "Sam" => 0, "Gandalf" => 2},
          "Gandalf" => {"Frodo" => 1, "Pippin" => 3, "Merry" => 2, "Sam" => 0}
        }
      end

      def test_matchmaking_pairs_when_third_participant_is_not_allowed
        strategy = @subject.new(allow_third_participant: false)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches, [["Merry", "Sam"], ["Frodo", "Pippin"]]
      end

      def test_matchmaking_pairs_when_third_participant_is_allowed
        strategy = @subject.new(allow_third_participant: true)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches, [["Merry", "Sam", "Gandalf"], ["Frodo", "Pippin"]]
      end

      def test_matchmaking_pairs_for_no_participants
        strategy = @subject.new

        matches = strategy.call({})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end

      def test_matchmaking_pairs_for_one_participant
        strategy = @subject.new

        matches = strategy.call({"Frodo" => {}})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end
    end
  end
end
