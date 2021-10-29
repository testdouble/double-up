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
      Matchmaking::Participant.new(
        id: "USER_ID_1",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_2")
        ],
        grouped_historical_matches: {}
      )
    )
  end

  it "adjusts score for candidates found in previous matches" do
    one_and_three_oldest = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_3"])
    one_and_three_newest = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_3"])
    one_and_four = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_4"])

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
      Matchmaking::Participant.new(
        id: "USER_ID_1",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_2"),
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_3", score: 2),
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_4", score: 1)
        ],
        grouped_historical_matches: {
          "test" => [one_and_three_oldest, one_and_three_newest, one_and_four]
        }
      )
    )
  end
end
