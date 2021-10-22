require "rails_helper"

RSpec.describe Matchmaking::MatchesParticipants do
  let(:seed) { 98765 }

  subject { Matchmaking::MatchesParticipants.new }

  before(:example) do
    srand(seed)
  end

  it "creates no matches for no participants" do
    matches = subject.call(participants: [])

    expect(matches).to eq([])
  end

  it "creates no matches for a single participant" do
    matches = subject.call(participants: ["USER_ID_1"])

    expect(matches).to eq([])
  end

  it "creates one match with all participants for two participants" do
    matches = subject.call(participants: ["USER_ID_1", "USER_ID_2"])

    expect(matches).to eq(["USER_ID_1", "USER_ID_2"])
  end
end
