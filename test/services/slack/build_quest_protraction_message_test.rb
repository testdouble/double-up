require "test_helper"

module Slack
  class BuildQuestProtractionMessageTest < ActiveSupport::TestCase
    setup do
      @subject = BuildQuestProtractionMessage.new
    end

    test "renders message as blocks" do
      match = create_historical_match(grouping: "test", members: ["Frodo", "Sam"])

      content = @subject.call(match: match)

      assert_blocks_match [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Hi <@Frodo> and <@Sam>!\n"
          }
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Are you done with your quest?\n"
          }
        },
        {
          type: "actions",
          elements: [
            {
              type: "button",
              text: {
                type: "plain_text",
                text: "Yes!"
              },
              action_id: "match:#{match.id}",
              value: "quest_complete"
            },
            {
              type: "button",
              text: {
                type: "plain_text",
                text: "No, we need more time"
              },
              action_id: "match:#{match.id}",
              value: "quest_continue"
            }
          ]
        }
      ], content
    end
  end
end
