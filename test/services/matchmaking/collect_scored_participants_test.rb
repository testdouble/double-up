require "test_helper"

module Matchmaking
  class CollectScoredParticipantsTest < ActiveSupport::TestCase
    setup do
      @assign_score_to_candidates = Mocktail.of_next(AssignScoreToCandidates)

      @subject = CollectScoredParticipants.new
      @participants = ["Frodo", "Sam", "Pippin", "Merry"]
      @group = group_with(name: "hobbits")

      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Frodo", "Sam"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Merry", "Pippin"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 20), grouping: "hobbits", members: ["Frodo", "Pippin"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 20), grouping: "hobbits", members: ["Sam", "Merry"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Frodo", "Sam"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Merry", "Pippin"])
    end

    test "score all candidates for each participant and return as hash" do
      stubs { |m| @assign_score_to_candidates.call(["Sam", "Pippin", "Merry"], m.any) }.with { {"Sam" => 2, "Pippin" => 1, "Merry" => 0} }
      stubs { |m| @assign_score_to_candidates.call(["Frodo", "Pippin", "Merry"], m.any) }.with { {"Frodo" => 2, "Pippin" => 0, "Merry" => 1} }
      stubs { |m| @assign_score_to_candidates.call(["Frodo", "Sam", "Merry"], m.any) }.with { {"Frodo" => 1, "Sam" => 0, "Merry" => 2} }
      stubs { |m| @assign_score_to_candidates.call(["Frodo", "Sam", "Pippin"], m.any) }.with { {"Frodo" => 0, "Sam" => 1, "Pippin" => 2} }

      result = @subject.call(@participants, @group)

      assert_equal({
        "Frodo" => {
          "Sam" => 2,
          "Pippin" => 1,
          "Merry" => 0
        },
        "Sam" => {
          "Frodo" => 2,
          "Pippin" => 0,
          "Merry" => 1
        },
        "Pippin" => {
          "Frodo" => 1,
          "Sam" => 0,
          "Merry" => 2
        },
        "Merry" => {
          "Frodo" => 0,
          "Sam" => 1,
          "Pippin" => 2
        }
      }, result)
    end
  end
end
