module Notify
  class UseSlackToDeliverNotification
    def initialize
      @opens_slack_conversation = Slack::OpensSlackConversation.new
      @sends_slack_message = Slack::SendsSlackMessage.new
      @builds_grouping_slack_message = Slack::BuildsGroupingSlackMessage.new
    end

    def call(notification, group)
      return unless notification.use_slack?

      match = notification.historical_match

      match_conversation = @opens_slack_conversation.call(users: match.members)

      @sends_slack_message.call(
        channel: match_conversation,
        # TODO refactor to pass match instead of match attributes
        blocks: @builds_grouping_slack_message.render(
          grouping: match.grouping,
          members: match.members,
          channel_name: group.slack_channel_name
        )
      )
    end

    private

    def channel_name_for_grouping(grouping)
      grouping_sym = grouping.intern

      raise "No config found for grouping '#{grouping}'" unless @config.respond_to?(grouping_sym)

      @config.send(grouping_sym)&.channel
    end
  end
end
