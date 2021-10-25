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
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_2", 0)
      ], {}),
      Matchmaking::Participant.new("USER_ID_2", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_1", 0)
      ], {})
    ])
  end

  it "returns a list of participants with historical matches when historical matches are found" do
    one_and_three = HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_3"], grouping: "test")
    participant_ids = ["USER_ID_1", "USER_ID_2", "USER_ID_3"]

    result = subject.call(participant_ids)

    expect(result).to eq([
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_2", 0),
        Matchmaking::ScoredMatchCandidate.new("USER_ID_3", 1)
      ], {
        "test" => [one_and_three]
      }),
      Matchmaking::Participant.new("USER_ID_2", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_1", 0),
        Matchmaking::ScoredMatchCandidate.new("USER_ID_3", 0)
      ], {}),
      Matchmaking::Participant.new("USER_ID_3", [
        Matchmaking::ScoredMatchCandidate.new("USER_ID_1", 1),
        Matchmaking::ScoredMatchCandidate.new("USER_ID_2", 0)
      ], {
        "test" => [one_and_three]
      })
    ])
  end
end
