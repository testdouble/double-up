require "test_helper"

module Rakes
  class SendPendingNotificationsTest < ActiveSupport::TestCase
    setup do
      @retrieves_pending_notifications = Mocktail.of_next(Notify::RetrievesPendingNotifications)
      @determines_retriability = Mocktail.of_next(Notify::DeterminesRetriability)
      @uses_email_to_deliver_notification = Mocktail.of_next(Notify::UsesEmailToDeliverNotification)
      @uses_slack_to_deliver_notification = Mocktail.of_next(Notify::UsesSlackToDeliverNotification)

      @subject = SendPendingNotifications
    end

    test "does not send any when no pending notifications are found" do
      config = matchmaking_config(test: {channel: "group-test", schedule: :daily})

      stubs { @retrieves_pending_notifications.call(grouping: :test) }.with { [] }

      @subject.new(config: config, stdout: stdout, stderr: stderr).call

      assert_equal "No pending notifications found for 'test'\n", read_output!
      assert_empty read_errors!
    end

    test "sends all pending notifications using their specified strategy" do
      email_notification = PendingNotification.new(strategy: "email")
      slack_notification = PendingNotification.new(strategy: "slack")
      match = create_historical_match(
        grouping: "test",
        members: ["Frodo", "Sam"],
        pending_notifications: [email_notification, slack_notification]
      )

      config = matchmaking_config(test: {channel: "group-test", schedule: :daily})

      stubs { @retrieves_pending_notifications.call(grouping: :test) }.with { match.pending_notifications }
      stubs(times: 2) { @determines_retriability.can_retry?(:daily, original_date: Date.today) }.with { true }
      stubs { @uses_slack_to_deliver_notification.call(notification: slack_notification) }
      stubs { @uses_email_to_deliver_notification.call(notification: email_notification) }

      @subject.new(config: config, stdout: stdout, stderr: stderr).call

      assert_match(/Sending notifications for 'test'/, read_output!)
      assert_empty read_errors!
    end

    test "deletes pending notification after send" do
      slack_notification = PendingNotification.new(strategy: "slack")
      match = create_historical_match(
        grouping: "test",
        members: ["Frodo", "Sam"],
        pending_notifications: [slack_notification]
      )

      config = matchmaking_config(test: {channel: "group-test", schedule: :daily})

      stubs { @retrieves_pending_notifications.call(grouping: :test) }.with { match.pending_notifications }
      stubs { @determines_retriability.can_retry?(:daily, original_date: Date.today) }.with { true }
      stubs { @uses_slack_to_deliver_notification.call(notification: slack_notification) }

      assert_difference("PendingNotification.count", -1) {
        @subject.new(config: config, stdout: stdout, stderr: stderr).call
      }
    end

    test "does not send notifications if they are not retriable" do
      six_months_ago = 6.months.ago.to_date
      slack_notification = PendingNotification.new(strategy: "slack", created_at: six_months_ago)
      match = create_historical_match(
        grouping: "test",
        members: ["Frodo", "Sam"],
        pending_notifications: [slack_notification]
      )

      config = matchmaking_config(test: {channel: "group-test", schedule: :daily})

      stubs { @retrieves_pending_notifications.call(grouping: :test) }.with { match.pending_notifications }

      assert_difference("PendingNotification.count", -1) {
        @subject.new(config: config, stdout: stdout, stderr: stderr).call
      }

      verify { @determines_retriability.can_retry?(:daily, original_date: six_months_ago) }

      assert_match(/Slack notification sent/, read_output!)
      assert_empty read_errors!
    end
  end
end
