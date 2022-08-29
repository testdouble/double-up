require "rails_helper"

RSpec.describe Rakes::RemovesOldMatches do
  it "removes matches from 3 months ago and keeps newer ones" do
    recent_match = HistoricalMatch.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["USER_ID1", "USER_ID2"],
      pending_notifications: [
        PendingNotification.create(strategy: "slack"),
        PendingNotification.create(strategy: "email")
      ]
    )

    older_match = HistoricalMatch.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["USER_ID1", "USER_ID2"],
      pending_notifications: [
        PendingNotification.create(strategy: "slack"),
        PendingNotification.create(strategy: "email")
      ],
      created_at: Date.today - 3.months - 1.day
    )

    subject = Rakes::RemovesOldMatches.new
    subject.call

    expect { older_match.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { recent_match.reload }.to_not raise_error
  end
end
