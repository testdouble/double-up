require "rails_helper"

RSpec.describe Matchmaking::CreateMatches do
  let(:seed) { 98765 }

  subject { Matchmaking::CreateMatches.new }

  before(:example) do
    srand(seed)
  end

  it "creates no matches for no participants" do
    matches = subject.call([])

    expect(matches).to eq([])
  end

  it "creates no matches for a single participant" do
    matches = subject.call(["USER_ID_1"])

    expect(matches).to eq([])
  end

  it "creates one match with all participants for two participants" do
    matches = subject.call(["USER_ID_1", "USER_ID_2"])

    expect(matches).to eq(["USER_ID_1", "USER_ID_2"])
  end
end
