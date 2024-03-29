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
          action_id = "match:#{match.id}"

          a.button(text: I18n.t("slack.message.quest_protraction.buttons.complete"), action_id: action_id, value: "quest_complete")
          a.button(text: I18n.t("slack.message.quest_protraction.buttons.continue"), action_id: action_id, value: "quest_continue")
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
