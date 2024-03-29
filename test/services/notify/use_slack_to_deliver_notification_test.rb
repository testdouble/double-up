require "test_helper"

module Notify
  class UseSlackToDeliverNotificationTest < ActiveSupport::TestCase
    setup do
      @opens_slack_conversation = Mocktail.of_next(Slack::OpensSlackConversation)
      @sends_slack_message = Mocktail.of_next(Slack::SendsSlackMessage)
      @builds_grouping_slack_message = Mocktail.of_next(Slack::BuildsGroupingSlackMessage)

      @group = group_with(name: "test", channel: "group-test", schedule: :daily)

      @subject = UseSlackToDeliverNotification.new
    end

    test "sends a single group slack message to all members" do
      notification = create_pending_slack_notification
      create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [notification]
      )

      stubs { @opens_slack_conversation.call(users: ["USER_ID_1", "USER_ID_2"]) }.with { "MPIM_ID" }
      stubs { @builds_grouping_slack_message.render(grouping: "test", members: ["USER_ID_1", "USER_ID_2"], channel_name: "test") }.with { [] }
      stubs { @sends_slack_message.call(channel: "MPIM_ID", blocks: []) }

      @subject.call(notification, @group)
    end

    test "does not send a slack message if the strategy is not slack" do
      notification = create_pending_email_notification
      create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [notification]
      )

      stubs { |m| @opens_slack_conversation.call(users: m.any) }.with { raise "Should not be called" }
      stubs { |m|
        @builds_grouping_slack_message.render(
          grouping: m.any,
          members: m.any,
          channel_name: m.any
        )
      }.with { raise "Should not be called" }
      stubs { |m| @sends_slack_message.call(channel: m.any, blocks: m.any) }.with { raise "Should not be called" }

      @subject.call(notification, @group)
    end
  end
end
