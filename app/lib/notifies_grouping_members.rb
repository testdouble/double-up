class NotifiesGroupingMembers
  def initialize
    @opens_slack_conversation = Slack::OpensSlackConversation.new
    @sends_slack_message = Slack::SendsSlackMessage.new
    @builds_grouping_slack_message = Slack::BuildsGroupingSlackMessage.new
  end

  def call(grouping:, members:, channel_name:)
    match_conversation = @opens_slack_conversation.call(users: members)

    @sends_slack_message.call(
      channel: match_conversation,
      blocks: @builds_grouping_slack_message.render(grouping: grouping, members: members, channel_name: channel_name)
    )
  end
end
