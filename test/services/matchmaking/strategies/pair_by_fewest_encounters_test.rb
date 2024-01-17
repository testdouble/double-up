require "test_helper"

module Matchmaking
  module Strategies
    class PairByFewestEncountersTest < ActiveSupport::TestCase
      setup do
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

      test "matchmaking pairs when third participant is not allowed" do
        strategy = @subject.new(allow_third_participant: false)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches, [["Merry", "Sam"], ["Frodo", "Pippin"]]
      end

      test "matchmaking pairs when third participant is allowed" do
        strategy = @subject.new(allow_third_participant: true)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches, [["Merry", "Sam", "Gandalf"], ["Frodo", "Pippin"]]
      end

      test "matchmaking pairs for no participants" do
        strategy = @subject.new

        matches = strategy.call({})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end

      test "matchmaking pairs for one participant" do
        strategy = @subject.new

        matches = strategy.call({"Frodo" => {}})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end
    end
  end
end
