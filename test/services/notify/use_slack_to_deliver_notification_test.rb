require "test_helper"

module Notify
  class UseSlackToDeliverNotificationTest < ActiveSupport::TestCase
    setup do
      @opens_slack_conversation = Mocktail.of_next(Slack::OpensSlackConversation)
      @send_slack_message = Mocktail.of_next(Slack::SendSlackMessage)
      @build_new_match_message = Mocktail.of_next(Slack::BuildNewMatchMessage)
      @build_quest_protraction_message = Mocktail.of_next(Slack::BuildQuestProtractionMessage)

      @group = group_with(name: "test", slack_channel_name: "group-test", schedule: :daily)

      @subject = UseSlackToDeliverNotification.new
    end

    test "sends a single group slack message to all members with new_match reason" do
      notification = create_pending_slack_notification
      match = create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [notification]
      )

      stubs { @opens_slack_conversation.call(users: ["USER_ID_1", "USER_ID_2"]) }.with { "MPIM_ID" }
      stubs { @build_new_match_message.call(match: match, channel_name: "test") }.with { [] }
      stubs { @send_slack_message.call(channel: "MPIM_ID", blocks: []) }

      @subject.call(notification, @group)
    end

    test "sends a single group slack message to all members with quest_protraction reason" do
      notification = create_pending_slack_notification(reason: "quest_protraction")
      match = create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [notification]
      )

      stubs { @opens_slack_conversation.call(users: ["USER_ID_1", "USER_ID_2"]) }.with { "MPIM_ID" }
      stubs { @build_quest_protraction_message.call(match: match) }.with { [] }
      stubs { @send_slack_message.call(channel: "MPIM_ID", blocks: []) }

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
      stubs { |m| @build_new_match_message.call(match: m.any, channel_name: m.any) }.with { raise "Should not be called" }
      stubs { |m| @build_quest_protraction_message.call(match: m.any) }.with { raise "Should not be called" }
      stubs { |m| @send_slack_message.call(channel: m.any, blocks: m.any) }.with { raise "Should not be called" }

      @subject.call(notification, @group)
    end
  end
end
