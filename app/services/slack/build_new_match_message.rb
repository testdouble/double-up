module Slack
  class BuildNewMatchMessage
    def initialize
      @humanize_names = Utils::HumanizeNames.new
    end

    def call(match:, channel_name:)
      Slack::BlockKit.blocks do |b|
        b.section do |s|
          s.mrkdwn(text: message_text(match, channel_name))
        end
      end
    end

    private

    def message_text(match, channel_name)
      group_name = match.grouping.to_s.titleize
      member_mentions = match.members.map { |m| I18n.t("slack.message.mention", slack_user_id: m) }
      humanized_mentions = @humanize_names.call(member_mentions)
      I18n.t("slack.message.new_match.body", mentions: humanized_mentions, channel_name: channel_name, group_name: group_name)
    end
  end
end
