require "test_helper"

module Slack
  class BuildLoginMessageTest < ActiveSupport::TestCase
    setup do
      @user = User.create(slack_user_id: "USER", auth_token: "12345", auth_token_expires_at: 1.minute.from_now)

      @subject = BuildLoginMessage.new
    end

    test "renders message as blocks" do
      content = @subject.call(user: @user)

      assert_blocks_match [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "Use <http://example.com/auth/verify?token=12345|this link> to login"
          }
        }
      ], content
    end
  end
end
