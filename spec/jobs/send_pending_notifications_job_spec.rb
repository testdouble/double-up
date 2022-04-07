require "rails_helper"

RSpec.describe SendPendingNotificationsJob do
  let(:config) { OpenStruct.new(test: OpenStruct.new(size: 2, channel: "group-test")) }

  before(:example) do
    @retrieves_pending_notifications = double(Notify::RetrievesPendingNotifications)

    allow(Notify::RetrievesPendingNotifications).to receive(:new) { @retrieves_pending_notifications }
  end

  it "sends all pending notifications and deletes when successful" do
    match = create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [
        PendingNotification.create(strategy: "email"),
        PendingNotification.create(strategy: "slack")
      ]
    )

    expect(@retrieves_pending_notifications).to receive(:call).with(grouping: "test") { match.pending_notifications }

    expect {
      SendPendingNotificationsJob.new(config: config).perform(grouping: "test")
    }.to change(PendingNotification, :count).by(-2)
  end
end
