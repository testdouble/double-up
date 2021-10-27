require "rails_helper"

RSpec.describe Matchmaking::MatchesParticipants do
  let(:config) { OpenStruct.new(test: OpenStruct.new(size: 2)) }
  let(:seed) { 98765 }

  subject { Matchmaking::MatchesParticipants.new(config: config) }

  before(:example) do
    srand(seed)
  end

  it "creates no matches for no participants" do
    matches = subject.call(grouping: "test", participant_ids: [])

    expect(matches).to eq([])
  end

  it "creates no matches for a single participant" do
    matches = subject.call(grouping: "test", participant_ids: ["USER_ID_1"])

    expect(matches).to eq([])
  end

  it "creates one match with all participants for two participants" do
    matches = subject.call(grouping: "test", participant_ids: ["USER_ID_1", "USER_ID_2"])

    expect(matches).to eq([
      Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_2"])
    ])
  end
end
