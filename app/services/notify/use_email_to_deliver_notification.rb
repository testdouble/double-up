module Notify
  class UseEmailToDeliverNotification
    def initialize
      @retrieves_slack_user_info = Slack::RetrievesSlackUserInfo.new
      @build_group_mailer_message = Mailer::BuildGroupMailerMessage.new
    end

    def call(notification, group)
      return unless notification.use_email?

      match = notification.historical_match

      member_users = match.members.map { |id| convert_to_match_member(id) }
      member_users.each do |user|
        mailer = @build_group_mailer_message.render(
          recipient: user,
          channel: group.slack_channel_name,
          grouping: match.grouping,
          other_members: member_users.reject { |u| u.email == user.email }
        )

        mailer.deliver_now
      end
    end

    private

    def convert_to_match_member(member_id)
      slack_user = @retrieves_slack_user_info.call(user: member_id)
      Mailer::MatchMember.from_slack_user(slack_user)
    end
  end
end
