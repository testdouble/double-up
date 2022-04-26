class NotifiesGroupingMembers
  def initialize
    @opens_slack_conversation = Slack::OpensSlackConversation.new
    @retrieves_slack_user_info = Slack::RetrievesSlackUserInfo.new
    @sends_slack_message = Slack::SendsSlackMessage.new
    @builds_grouping_slack_message = Slack::BuildsGroupingSlackMessage.new
    @builds_grouping_mailer_message = Mailer::BuildsGroupingMailerMessage.new
  end

  def call(grouping:, members:, channel_name:)
    match_conversation = @opens_slack_conversation.call(users: members)

    @sends_slack_message.call(
      channel: match_conversation,
      blocks: @builds_grouping_slack_message.render(grouping: grouping, members: members, channel_name: channel_name)
    )

    # Turn off email for now
    # member_users = members.map { |id| convert_to_match_member(id) }
    # member_users.each do |user|
    #   @builds_grouping_mailer_message.render(
    #     recipient: user,
    #     channel: channel_name,
    #     grouping: grouping,
    #     other_members: member_users.reject { |u| u.email == user.email }
    #   ).deliver_now
    # end
  end

  private

  def convert_to_match_member(member_id)
    Mailer::MatchMember.from_slack_user(@retrieves_slack_user_info.call(user: member_id))
  end
end
