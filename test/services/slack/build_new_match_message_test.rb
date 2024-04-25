require "test_helper"

module Slack
  class BuildNewMatchMessageTest < ActiveSupport::TestCase
    setup do
      @subject = BuildNewMatchMessage.new
    end

    test "renders message as blocks for a match with 2 members" do
      match = create_historical_match(grouping: "test", members: ["Frodo", "Sam"])

      content = @subject.call(match: match, channel_name: "group-test")

      assert_blocks_match [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":wave: Hi <@Frodo> and <@Sam>! You've been matched up for Test from #group-test! Find a time to meet, and have fun!\n"
          }
        }
      ], content
    end

    test "renders message as blocks for a match with 3 members" do
      match = create_historical_match(grouping: "test", members: ["Frodo", "Sam", "Pippin"])

      content = @subject.call(match: match, channel_name: "group-test")

      assert_blocks_match [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: ":wave: Hi <@Frodo>, <@Sam>, and <@Pippin>! You've been matched up for Test from #group-test! Find a time to meet, and have fun!\n"
          }
        }
      ], content
    end
  end
end
