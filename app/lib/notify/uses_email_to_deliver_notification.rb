module Notify
  class UsesEmailToDeliverNotification
    def initialize(config: nil)
      @retrieves_slack_user_info = Slack::RetrievesSlackUserInfo.new
      @builds_grouping_mailer_message = Mailer::BuildsGroupingMailerMessage.new

      @config = config || Rails.application.config.x.matchmaking
    end

    def call(notification:)
      return unless notification.use_email?

      match = notification.historical_match

      channel_name = channel_name_for_grouping(match.grouping)

      member_users = match.members.map { |id| convert_to_match_member(id) }
      member_users.each do |user|
        @builds_grouping_mailer_message.render(
          recipient: user,
          channel: channel_name,
          grouping: match.grouping,
          other_members: member_users.reject { |u| u.email == user.email }
        ).deliver_now
      end
    end

    private

    def convert_to_match_member(member_id)
      Mailer::MatchMember.from_slack_user(@retrieves_slack_user_info.call(user: member_id))
    end

    def channel_name_for_grouping(grouping)
      grouping_sym = grouping.intern

      raise "No config found for grouping '#{grouping}'" unless @config.respond_to?(grouping_sym)

      @config.send(grouping_sym)&.channel
    end
  end
end
