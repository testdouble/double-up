require "rails_helper"

RSpec.describe Matchmaking::ScoresParticipantCandidates, type: :matchmaking do
  subject { Matchmaking::ScoresParticipantCandidates.new }

  it "does not change score when no historical match exists" do
    participant = new_participant(
      id: "USER_ID_1",
      match_candidates: [new_match_candidate(id: "USER_ID_2")],
      historical_matches: []
    )

    result = subject.call(participant: participant)

    expect(result).to eq(
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_2", 0)
      ], {})
    )
  end

  it "adjusts score for candidates found in previous matches" do
    one_and_three_oldest = HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_3"], grouping: "test")
    one_and_three_newest = HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_3"], grouping: "test")
    one_and_four = HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_4"], grouping: "test")

    participant = new_participant(
      id: "USER_ID_1",
      match_candidates: [
        new_match_candidate(id: "USER_ID_2"),
        new_match_candidate(id: "USER_ID_3"),
        new_match_candidate(id: "USER_ID_4")
      ],
      historical_matches: [
        one_and_three_oldest,
        one_and_three_newest,
        one_and_four
      ]
    )

    result = subject.call(participant: participant)

    expect(result).to eq(
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_2", 0),
        Matchmaking::ScoredMatchCandidate.new("USER_ID_3", 2),
        Matchmaking::ScoredMatchCandidate.new("USER_ID_4", 1)
      ], {
        "test" => [one_and_three_oldest, one_and_three_newest, one_and_four]
      })
    )
  end
end
