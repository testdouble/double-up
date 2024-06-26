require "test_helper"

module Rakes
  class SendPendingNotificationsTest < ActiveSupport::TestCase
    setup do
      @collect_groups = Mocktail.of_next(CollectGroups)
      @retrieves_pending_notifications = Mocktail.of_next(Notify::RetrievesPendingNotifications)
      @determines_retriability = Mocktail.of_next(Notify::DeterminesRetriability)
      @use_email_to_deliver_notification = Mocktail.of_next(Notify::UseEmailToDeliverNotification)
      @use_slack_to_deliver_notification = Mocktail.of_next(Notify::UseSlackToDeliverNotification)

      @subject = SendPendingNotifications
    end

    test "does not send any when no pending notifications are found" do
      groups = [
        group_with(name: "test", slack_channel_name: "group-test", schedule: :daily)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @retrieves_pending_notifications.call(grouping: "test") }.with { [] }

      @subject.new(stdout: stdout, stderr: stderr).call

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

      groups = [
        group_with(name: "test", slack_channel_name: "group-test", schedule: :daily)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @retrieves_pending_notifications.call(grouping: "test") }.with { match.pending_notifications }
      stubs(times: 2) { @determines_retriability.can_retry?(:daily, original_date: Date.today) }.with { true }
      stubs { @use_slack_to_deliver_notification.call(slack_notification, groups.first) }
      stubs { @use_email_to_deliver_notification.call(email_notification, groups.first) }

      @subject.new(stdout: stdout, stderr: stderr).call

      assert_match(/Sending new_match notification for 'test'/, read_output!)
      assert_empty read_errors!
    end

    test "deletes pending notification after send" do
      slack_notification = PendingNotification.new(strategy: "slack")
      match = create_historical_match(
        grouping: "test",
        members: ["Frodo", "Sam"],
        pending_notifications: [slack_notification]
      )

      groups = [
        group_with(name: "test", slack_channel_name: "group-test", schedule: :daily)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @retrieves_pending_notifications.call(grouping: "test") }.with { match.pending_notifications }
      stubs { @determines_retriability.can_retry?(:daily, original_date: Date.today) }.with { true }
      stubs { @use_slack_to_deliver_notification.call(slack_notification, groups.first) }

      assert_difference("PendingNotification.count", -1) {
        @subject.new(stdout: stdout, stderr: stderr).call
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

      groups = [
        group_with(name: "test", slack_channel_name: "group-test", schedule: :daily)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @retrieves_pending_notifications.call(grouping: "test") }.with { match.pending_notifications }

      assert_difference("PendingNotification.count", -1) {
        @subject.new(stdout: stdout, stderr: stderr).call
      }

      verify { @determines_retriability.can_retry?("daily", original_date: six_months_ago) }

      assert_match(/Slack notification sent/, read_output!)
      assert_empty read_errors!
    end
  end
end
