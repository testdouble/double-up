require "test_helper"

module Auth
  class SendLoginLinkTest < ActiveSupport::TestCase
    setup do
      @finds_or_creates_user = Mocktail.of_next(FindsOrCreatesUser)
      @generates_token = Mocktail.of_next(GeneratesToken)
      @build_login_message = Mocktail.of_next(Slack::BuildLoginMessage)
      @opens_slack_conversation = Mocktail.of_next(Slack::OpensSlackConversation)
      @sends_slack_message = Mocktail.of_next(Slack::SendsSlackMessage)

      @subject = SendLoginLink.new
    end

    test "does not send if a user could not be found or created" do
      stubs { @finds_or_creates_user.call("NONE") }.with { nil }
      stubs { |m| @generates_token.call(m.any) }.with { raise "Should not be called" }

      @subject.call(slack_user_id: "NONE")
    end

    test "generates a token and sends a message to the slack user" do
      user = create_user(slack_user_id: "USER")
      token = "z" * 22

      stubs { @finds_or_creates_user.call("USER") }.with { user }
      stubs { @generates_token.call(user) }.with { token }
      stubs { @build_login_message.call(user: user) }.with { [] }
      stubs { @opens_slack_conversation.call(users: ["USER"]) }.with { "DM_ID" }
      stubs { @sends_slack_message.call(channel: "DM_ID", blocks: []) }

      @subject.call(slack_user_id: "USER")
    end
  end
end
