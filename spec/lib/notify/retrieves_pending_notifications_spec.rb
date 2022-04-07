require "rails_helper"

RSpec.describe Notify::RetrievesPendingNotifications do
  let(:subject) { Notify::RetrievesPendingNotifications.new }

  before(:example) do
  end

  it "returns an empty array when no pending notifications are found" do
    pending_notifications = subject.call(grouping: "test")

    expect(pending_notifications).to be_empty
  end

  it "returns all pending notifications for a grouping" do
    match = create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [
        PendingNotification.create(strategy: "email"),
        PendingNotification.create(strategy: "slack")
      ]
    )

    pending_notifications = subject.call(grouping: "test")

    expect(pending_notifications).to match(match.pending_notifications)
  end
end
