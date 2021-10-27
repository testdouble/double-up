require "rails_helper"

RSpec.describe Matchmaking::BuildsParticipants, type: :matchmaking do
  subject { Matchmaking::BuildsParticipants.new }

  it "returns empty list for no participants" do
    result = subject.call([])

    expect(result).to eq([])
  end

  it "returns a list of participants with no historical matches when no historical matches are found" do
    participant_ids = ["USER_ID_1", "USER_ID_2"]

    result = subject.call(participant_ids)

    expect(result).to eq([
      Matchmaking::Participant.new(
        id: "USER_ID_1",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_2")
        ],
        grouped_historical_matches: {}
      ),
      Matchmaking::Participant.new(
        id: "USER_ID_2",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_1")
        ],
        grouped_historical_matches: {}
      )
    ])
  end

  it "returns a list of participants with historical matches when historical matches are found" do
    one_and_three = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_3"])
    participant_ids = ["USER_ID_1", "USER_ID_2", "USER_ID_3"]

    result = subject.call(participant_ids)

    expect(result).to eq([
      Matchmaking::Participant.new(
        id: "USER_ID_1",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_2"),
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_3", score: 1)
        ],
        grouped_historical_matches: {
          "test" => [one_and_three]
        }
      ),
      Matchmaking::Participant.new(
        id: "USER_ID_2",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_1"),
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_3")
        ],
        grouped_historical_matches: {}
      ),
      Matchmaking::Participant.new(
        id: "USER_ID_3",
        match_candidates: [
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_1", score: 1),
          Matchmaking::ScoredMatchCandidate.new(id: "USER_ID_2")
        ],
        grouped_historical_matches: {
          "test" => [one_and_three]
        }
      )
    ])
  end
end
