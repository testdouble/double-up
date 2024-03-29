require "test_helper"

module Slack
  class SendSlackMessageTest < ActiveSupport::TestCase
    setup do
      @subject = SendSlackMessage.new
    end

    test "sends a slack message" do
      slack_user_im = slack_im_message("USER_IM_ID", "USER_ID")

      stub_slack_client do |slack_client|
        @subject.call(channel: slack_user_im.id, blocks: [{type: "section", text: {type: "plain_text", text: "Hello World"}}])

        verify { slack_client.chat_postMessage(channel: "USER_IM_ID", blocks: [{type: "section", text: {type: "plain_text", text: "Hello World"}}]) }
      end
    end

    test "accepts a BlockKit instance for blocks" do
      slack_user_im = slack_im_message("USER_IM_ID", "USER_ID")
      blocks = Slack::BlockKit.blocks do |b|
        b.section do |s|
          s.plain_text(text: "Hello World")
        end
      end

      stub_slack_client do |slack_client|
        @subject.call(channel: slack_user_im.id, blocks: blocks)

        verify { slack_client.chat_postMessage(channel: "USER_IM_ID", blocks: [{type: "section", text: {type: "plain_text", text: "Hello World"}}].to_json) }
      end
    end

    private

    def slack_im_message(id, user_id)
      Slack::Messages::Message.new(
        id: id,
        user: Slack::Messages::Message.new(id: user_id)
      )
    end
  end
end
