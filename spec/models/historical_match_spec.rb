require "rails_helper"

RSpec.describe HistoricalMatch, type: :model do
  it "requires at least two members" do
    match = HistoricalMatch.create(members: ["USER_ID_1"])

    expect(match.valid?).to be false
    expect(match.errors[:members].first).to eq("must include multiple members")
  end

  it "requires matched_on attribute" do
    match = HistoricalMatch.create

    expect(match.valid?).to be false
    expect(match.errors[:matched_on].first).to eq("can't be blank")
  end

  it "requires grouping attribute" do
    match = HistoricalMatch.create

    expect(match.valid?).to be false
    expect(match.errors[:grouping].first).to eq("can't be blank")
  end

  it "creates successfully" do
    match = HistoricalMatch.create(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      matched_on: Date.today
    )

    expect(match.valid?).to be true
    expect(match.errors).to be_empty
  end
end
