module Auth
  class SendLoginLink
    def initialize
      @finds_or_creates_user = FindsOrCreatesUser.new
      @generates_token = GeneratesToken.new
      @build_login_message = Slack::BuildLoginMessage.new
      @opens_slack_conversation = Slack::OpensSlackConversation.new
      @sends_slack_message = Slack::SendsSlackMessage.new
    end

    def call(slack_user_id:)
      user = @finds_or_creates_user.call(slack_user_id)
      return unless user

      @generates_token.call(user)

      conversation = @opens_slack_conversation.call(users: [slack_user_id])

      @sends_slack_message.call(
        channel: conversation,
        blocks: @build_login_message.call(user: user)
      )
    end
  end
end
