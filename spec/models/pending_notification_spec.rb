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

  describe ".for_grouping scope" do
    it "returns pending notifications for a particular grouping" do
      test_match = create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [
          PendingNotification.create(strategy: "slack")
        ]
      )
      other_match = create_historical_match(
        grouping: "other",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [
          PendingNotification.create(strategy: "slack")
        ]
      )

      pending_notifications = PendingNotification.for_grouping("test")

      expect(pending_notifications).to match(test_match.pending_notifications)
      expect(pending_notifications).to_not match(other_match.pending_notifications)
    end
  end

  describe "use_slack?" do
    it "returns true when strategy is slack" do
      notification = PendingNotification.new(strategy: "slack")

      expect(notification.use_slack?).to be true
    end

    it "returns false when strategy is not slack" do
      notification = PendingNotification.new(strategy: "email")

      expect(notification.use_slack?).to be false
    end
  end

  describe "use_email?" do
    it "returns true when strategy is email" do
      notification = PendingNotification.new(strategy: "email")

      expect(notification.use_email?).to be true
    end

    it "returns false when strategy is not email" do
      notification = PendingNotification.new(strategy: "slack")

      expect(notification.use_email?).to be false
    end
  end
end
