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
      group_without_channel = group_with(name: "test", slack_channel_name: nil)

      assert_raises(Errors::NoConfiguredChannel, "No configured channel for grouping 'test'") {
        @subject.call(group_without_channel)
      }
    end

    test "raises error when no channel found with name" do
      group = group_with(name: "test", slack_channel_name: "test")

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
      group = group_with(name: "test", slack_channel_name: "group-test")

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

    test "does not match members who are unavailable due to their match being protracted" do
      group = group_with(name: "test", slack_channel_name: "group-test")

      match = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_4"])
      ProtractedMatch.create!(historical_match: match)

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
      stubs { @match_participants.call(["USER_ID_2", "USER_ID_3", "USER_ID_5"], group) }.with {
        [["USER_ID_2", "USER_ID_3", "USER_ID_5"]]
      }

      assert_difference("HistoricalMatch.count", 1) {
        assert_difference("PendingNotification.new_match_reason.count", 2) {
          @subject.call(group)
        }
      }
    end

    test "creates quest_protraction notifications for protracted matches" do
      group = group_with(name: "test", slack_channel_name: "group-test")

      match1 = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_4"])
      match2 = create_historical_match(grouping: "test", members: ["USER_ID_2", "USER_ID_3"])
      ProtractedMatch.create!(historical_match: match1)
      ProtractedMatch.create!(historical_match: match2)

      stubs { @loads_slack_channels.call(types: "public_channel") }.with {
        [
          Slack::Messages::Message.new(id: "CHANNEL_ID_1", name_normalized: "general"),
          Slack::Messages::Message.new(id: "CHANNEL_ID_2", name_normalized: "group-test"),
          Slack::Messages::Message.new(id: "CHANNEL_ID_3", name_normalized: "random")
        ]
      }
      stubs { @loads_slack_channel_members.call(channel: "CHANNEL_ID_2") }.with {
        ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4"]
      }
      stubs { @match_participants.call([], group) }.with { [[]] }

      assert_difference("PendingNotification.quest_protraction_reason.count", 2) {
        assert_difference("PendingNotification.new_match_reason.count", 0) {
          @subject.call(group)
        }
      }
    end
  end
end
