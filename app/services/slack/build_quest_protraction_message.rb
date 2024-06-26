module Slack
  class BuildQuestProtractionMessage
    def initialize
      @humanize_names = Utils::HumanizeNames.new
    end

    def call(match:)
      Slack::BlockKit.blocks do |b|
        b.section do |s|
          s.mrkdwn(text: saluations_text(match))
        end
        b.section do |s|
          s.mrkdwn(text: I18n.t("slack.message.quest_protraction.body"))
        end
        b.actions do |a|
          value = match.id.to_s

          a.button(text: I18n.t("slack.message.quest_protraction.buttons.complete"), action_id: "quest_complete", value: value)
          a.button(text: I18n.t("slack.message.quest_protraction.buttons.continue"), action_id: "quest_continue", value: value)
        end
      end
    end

    private

    def saluations_text(match)
      member_mentions = match.members.map { |m| I18n.t("slack.message.mention", slack_user_id: m) }
      humanized_mentions = @humanize_names.call(member_mentions)
      I18n.t("slack.message.quest_protraction.salutation", mentions: humanized_mentions)
    end
  end
end
