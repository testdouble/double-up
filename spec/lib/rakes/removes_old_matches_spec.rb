require "rails_helper"

RSpec.describe Rakes::RemovesOldMatches do
  it "archives matches from 3 months ago and keeps newer ones" do
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

    expect(older_match.reload.archived?).to be true
    expect(recent_match.reload.scoreable?).to be true
  end

  it "deletes matches from 2 years ago and keeps newer ones" do
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
      created_at: Date.today - 2.years - 1.day
    )

    subject = Rakes::RemovesOldMatches.new
    subject.call

    expect { older_match.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { recent_match.reload }.to_not raise_error
  end
end
