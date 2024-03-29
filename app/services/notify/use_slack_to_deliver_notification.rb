module Notify
  class UseSlackToDeliverNotification
    def initialize
      @opens_slack_conversation = Slack::OpensSlackConversation.new
      @sends_slack_message = Slack::SendsSlackMessage.new
      @build_new_match_message = Slack::BuildNewMatchMessage.new
    end

    def call(notification, group)
      return unless notification.use_slack?

      match = notification.historical_match

      match_conversation = @opens_slack_conversation.call(users: match.members)

      @sends_slack_message.call(
        channel: match_conversation,
        blocks: @build_new_match_message.call(match: match, channel_name: group.slack_channel_name)
      )
    end
  end
end
