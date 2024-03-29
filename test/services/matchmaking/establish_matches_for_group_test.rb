require "test_helper"

module Matchmaking
  class EstablishMatchesForGroupTest < ActiveSupport::TestCase
    setup do
      srand(98765)

      @loads_slack_channels = Mocktail.of_next(Slack::LoadsSlackChannels)
      @loads_slack_channel_members = Mocktail.of_next(Slack::LoadsSlackChannelMembers)
      @match_participants = Mocktail.of_next(Matchmaking::MatchParticipants)

      @subject = EstablishMatchesForGroup.new
    end

    test "raises error when grouping has configured channel" do
      group_without_channel = group_with(name: "test", channel: nil)

      assert_raises(Errors::NoConfiguredChannel, "No configured channel for grouping 'test'") {
        @subject.call(group_without_channel)
      }
    end

    test "raises error when no channel found with name" do
      group = group_with(name: "test", channel: "test")

      stubs { @loads_slack_channels.call(types: "public_channel") }.with {
        [
          Slack::Messages::Message.new(id: "CHANNEL_ID_1", name_normalized: "general"),
          Slack::Messages::Message.new(id: "CHANNEL_ID_2", name_normalized: "random")
        ]
      }

      assert_raises(Errors::ChannelNotFound, "No channel found with name 'test' for grouping 'test'") {
        @subject.call(group)
      }
    end

    test "matches members of a specific channel and records the match" do
      group = group_with(name: "test", channel: "group-test")

      stubs { @loads_slack_channels.call(types: "public_channel") }.with {
        [
          Slack::Messages::Message.new(id: "CHANNEL_ID_1", name_normalized: "general"),
          Slack::Messages::Message.new(id: "CHANNEL_ID_2", name_normalized: "group-test"),
          Slack::Messages::Message.new(id: "CHANNEL_ID_3", name_normalized: "random")
        ]
      }
      stubs { @loads_slack_channel_members.call(channel: "CHANNEL_ID_2") }.with {
        ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"]
      }
      stubs { @match_participants.call(["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"], group) }.with {
        [["USER_ID_1", "USER_ID_2", "USER_ID_5"], ["USER_ID_3", "USER_ID_4"]]
      }

      assert_difference("HistoricalMatch.count", 2) {
        assert_difference("PendingNotification.count", 4) {
          @subject.call(group)
        }
      }
    end
  end
end
