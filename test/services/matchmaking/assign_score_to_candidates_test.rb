require "test_helper"

module Matchmaking
  class AssignScoreToCandidatesTest < ActiveSupport::TestCase
    setup do
      @subject = AssignScoreToCandidates
      @candidates = ["Sam", "Pippin", "Merry", "Gandalf", "Aragorn", "Gollum"]
      @recent_matches = [
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 19), members: ["Frodo", "Sam"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 20), members: ["Frodo", "Pippin"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 21), members: ["Frodo", "Merry"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 22), members: ["Frodo", "Aragorn"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 23), members: ["Frodo", "Sam"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 24), members: ["Frodo", "Gandalf"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 25), members: ["Frodo", "Sam"]),
        HistoricalMatch.new(matched_on: Date.new(2002, 12, 26), members: ["Frodo", "Merry"])
      ]
    end

    test "assign score to candidates" do
      service = @subject.new

      result = service.call(@candidates, @recent_matches)

      assert_equal result, {
        "Sam" => 7.5,
        "Pippin" => 1,
        "Merry" => 6,
        "Gandalf" => 2,
        "Aragorn" => 1,
        "Gollum" => 0
      }
    end
  end
end
