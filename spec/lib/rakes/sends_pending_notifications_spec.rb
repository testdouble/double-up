require "rails_helper"

RSpec.describe Rakes::SendsPendingNotifications do
  before(:example) do
    @stdout = StringIO.new
    @stderr = StringIO.new

    @retrieves_pending_notifications = double(Notify::RetrievesPendingNotifications)
    allow(Notify::RetrievesPendingNotifications).to receive(:new) { @retrieves_pending_notifications }

    @determines_retriability = double(Notify::DeterminesRetriability)
    allow(Notify::DeterminesRetriability).to receive(:new) { @determines_retriability }

    @uses_email_to_deliver_notification = double(Notify::UsesEmailToDeliverNotification)
    allow(Notify::UsesEmailToDeliverNotification).to receive(:new) { @uses_email_to_deliver_notification }

    @uses_slack_to_deliver_notification = double(Notify::UsesSlackToDeliverNotification)
    allow(Notify::UsesSlackToDeliverNotification).to receive(:new) { @uses_slack_to_deliver_notification }
  end

  it "does not send any when no pending notifications are found" do
    expect(@retrieves_pending_notifications).to receive(:call).with(grouping: :test) { [] }
    expect(@determines_retriability).to_not receive(:can_retry?)
    expect(@uses_slack_to_deliver_notification).to_not receive(:call)
    expect(@uses_email_to_deliver_notification).to_not receive(:call)

    subject = Rakes::SendsPendingNotifications.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: true, size: 2, channel: "group-test", schedule: :daily)
      )
    )
    subject.call

    output = output!
    expect(output).to match(/No pending notifications found for 'test'/)
    expect(errors!).to be_empty
  end

  it "sends all pending notifications using their specified strategy" do
    email_notification = PendingNotification.new(strategy: "email")
    slack_notification = PendingNotification.new(strategy: "slack")
    match = create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [email_notification, slack_notification]
    )

    expect(@retrieves_pending_notifications).to receive(:call).with(grouping: :test) { match.pending_notifications }
    expect(@determines_retriability).to receive(:can_retry?).with(:daily, original_date: Date.today) { true }.twice
    expect(@uses_slack_to_deliver_notification).to receive(:call).with(notification: slack_notification)
    expect(@uses_email_to_deliver_notification).to receive(:call).with(notification: email_notification)

    subject = Rakes::SendsPendingNotifications.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: true, size: 2, channel: "group-test", schedule: :daily)
      )
    )
    subject.call

    output = output!
    expect(output).to match(/Sending notifications for 'test'/)
  end

  it "deletes pending notification after send" do
    slack_notification = PendingNotification.new(strategy: "slack")
    match = create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [slack_notification]
    )

    expect(@retrieves_pending_notifications).to receive(:call).with(grouping: :test) { match.pending_notifications }
    expect(@determines_retriability).to receive(:can_retry?).with(:daily, original_date: Date.today) { true }
    expect(@uses_slack_to_deliver_notification).to receive(:call).with(notification: slack_notification)

    subject = Rakes::SendsPendingNotifications.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: true, size: 2, channel: "group-test", schedule: :daily)
      )
    )

    expect { subject.call }.to change(PendingNotification, :count).by(-1)

    output = output!
    expect(output).to match(/Slack notification sent/)
  end

  it "does not send notifications if after retribility limit" do
    slack_notification = PendingNotification.new(strategy: "slack", created_at: Date.civil(2022, 1, 3))
    match = create_historical_match(
      grouping: "test",
      members: ["USER_ID_1", "USER_ID_2"],
      pending_notifications: [slack_notification]
    )

    expect(@retrieves_pending_notifications).to receive(:call).with(grouping: :test) { match.pending_notifications }
    expect(@determines_retriability).to receive(:can_retry?).with(:daily, original_date: Date.civil(2022, 1, 3)) { false }
    expect(@uses_slack_to_deliver_notification).to_not receive(:call)

    subject = Rakes::SendsPendingNotifications.new(
      stdout: @stdout, stderr: @stderr, config: OpenStruct.new(
        test: OpenStruct.new(active: true, size: 2, channel: "group-test", schedule: :daily)
      )
    )

    expect { subject.call }.to change(PendingNotification, :count).by(-1)

    output = output!
    expect(output).to match(/Slack notification sent/)
  end

  def output!
    read_and_reset(@stdout)
  end

  def errors!
    read_and_reset(@stderr)
  end

  def read_and_reset(io)
    io.tap(&:rewind).read.tap do
      io.truncate(0)
      io.rewind
    end
  end
end
