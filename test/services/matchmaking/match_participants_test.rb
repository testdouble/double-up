require "test_helper"

module Matchmaking
  class MatchParticipantsTest < ActiveSupport::TestCase
    setup do
      @subject = MatchParticipants
      @participants = ["Frodo", "Sam", "Merry", "Pippin", "Gandalf"]
      @choose_strategy = Mocktail.of_next(ChooseStrategy)
      @collect_scored_participants = Mocktail.of_next(CollectScoredParticipants)
      @strategy = Mocktail.of(Strategies::ArrangeGroupsGenetically)
    end

    test "returns an empty array if there are no participants" do
      assert_equal [], @subject.new.call([], "test")
    end

    test "returns an empty array if there is only one participant" do
      assert_equal [], @subject.new.call(["1"], "test")
    end

    test "returns matches" do
      expected_scored_participants = {
        "Frodo" => {"Sam" => 3, "Merry" => 1, "Pippin" => 0, "Gandalf" => 2},
        "Sam" => {"Frodo" => 3, "Merry" => 2, "Pippin" => 1, "Gandalf" => 0},
        "Merry" => {"Frodo" => 1, "Sam" => 2, "Pippin" => 3, "Gandalf" => 0},
        "Pippin" => {"Frodo" => 0, "Sam" => 1, "Merry" => 3, "Gandalf" => 2},
        "Gandalf" => {"Frodo" => 2, "Sam" => 0, "Merry" => 0, "Pippin" => 2}
      }

      stubs { @collect_scored_participants.call(@participants, "test") }.with { expected_scored_participants }
      stubs { @choose_strategy.call("test") }.with { @strategy }
      stubs { @strategy.call(expected_scored_participants) }.with { [["Frodo", "Sam", "Pippin"], ["Merry", "Gandalf"]] }

      matches = @subject.new.call(@participants, "test")

      assert_equal [["Frodo", "Sam", "Pippin"], ["Merry", "Gandalf"]], matches
    end
  end
end
