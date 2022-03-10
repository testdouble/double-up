require "rails_helper"

RSpec.describe PendingNotification, type: :model do
  it "requires historical_match reference" do
    match = PendingNotification.create

    expect(match.valid?).to be false
    expect(match.errors[:historical_match].first).to eq("must exist")
  end

  it "requires strategy to be a valid value" do
    match = PendingNotification.create(strategy: "other")

    expect(match.valid?).to be false
    expect(match.errors[:strategy].first).to eq("other is not a valid notification strategy")
  end

  it "creates successfully for slack" do
    match = PendingNotification.create(
      strategy: "slack",
      last_attempted_on: Date.today,
      historical_match: HistoricalMatch.create(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        matched_on: Date.yesterday
      )
    )

    expect(match.valid?).to be true
    expect(match.errors).to be_empty
  end

  it "creates successfully for email" do
    match = PendingNotification.create(
      strategy: "email",
      last_attempted_on: Date.today,
      historical_match: HistoricalMatch.create(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        matched_on: Date.yesterday
      )
    )

    expect(match.valid?).to be true
    expect(match.errors).to be_empty
  end
end
