require "test_helper"

class EstablishMatchesForGroupingJobTest < ActiveSupport::TestCase
  setup do
    srand(98765)

    @subject = EstablishMatchesForGroupingJob
    @loads_slack_channels = Mocktail.of_next(Slack::LoadsSlackChannels)
    @loads_slack_channel_members = Mocktail.of_next(Slack::LoadsSlackChannelMembers)
    @match_participants = Mocktail.of_next(Matchmaking::MatchParticipants)
  end

  test "raises error when grouping has no associated config" do
    config = matchmaking_config(test: {size: 2, channel: "test"})

    assert_raises("No config found for grouping 'unknown'") {
      @subject.new(config: config).perform(grouping: "unknown")
    }
  end

  test "raises error when grouping has configured channel" do
    config_without_channel = matchmaking_config(test: {size: 2, channel: nil})

    assert_raises("No configured channel for grouping 'test'") {
      @subject.new(config: config_without_channel).perform(grouping: "test")
    }
  end

  test "matches members of a specific channel and records the match" do
    config = matchmaking_config(test: {size: 2, channel: "group-test"})

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
    stubs { @match_participants.call(["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"], "test") }.with {
      [["USER_ID_1", "USER_ID_2", "USER_ID_5"], ["USER_ID_3", "USER_ID_4"]]
    }

    assert_difference("HistoricalMatch.count", 2) {
      assert_difference("PendingNotification.count", 4) {
        @subject.new(config: config).perform(grouping: "test")
      }
    }
  end
end
