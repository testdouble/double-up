module Matchmaking
  class CollectScoredParticipantsTest < ActiveSupport::TestCase
    setup do
      @subject = CollectScoredParticipants
      @participants = ["Frodo", "Sam", "Pippin", "Merry"]

      @assign_score_to_candidate = Mocktail.of_next(AssignScoreToCandidates)

      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Frodo", "Sam"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Merry", "Pippin"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 20), grouping: "hobbits", members: ["Frodo", "Pippin"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 20), grouping: "hobbits", members: ["Sam", "Merry"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Frodo", "Sam"])
      HistoricalMatch.create!(matched_on: Date.new(2002, 12, 19), grouping: "hobbits", members: ["Merry", "Pippin"])
    end

    test "score all candidates for each participant and return as hash" do
      stubs { |m| @assign_score_to_candidate.call(["Sam", "Pippin", "Merry"], m.any) }.with { {"Sam" => 2, "Pippin" => 1, "Merry" => 0} }
      stubs { |m| @assign_score_to_candidate.call(["Frodo", "Pippin", "Merry"], m.any) }.with { {"Frodo" => 2, "Pippin" => 0, "Merry" => 1} }
      stubs { |m| @assign_score_to_candidate.call(["Frodo", "Sam", "Merry"], m.any) }.with { {"Frodo" => 1, "Sam" => 0, "Merry" => 2} }
      stubs { |m| @assign_score_to_candidate.call(["Frodo", "Sam", "Pippin"], m.any) }.with { {"Frodo" => 0, "Sam" => 1, "Pippin" => 2} }

      service = @subject.new

      result = service.call(@participants, "hobbits")

      assert_equal result, {
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
      }
    end
  end
end
