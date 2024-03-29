module Slack
  class HandleInteraction
    def initialize(payload)
      @user = payload["user"]
      @actions = payload["actions"]

      @send_response_message = SendResponseMessage.new(payload["response_url"])
    end

    def call
      @actions.each do |action|
        case action["action_id"]
        when "quest_complete"
          handle_quest_complete(action)
        when "quest_continue"
          handle_quest_continue(action)
        else
          handle_unknown_action
        end
      end
    end

    private

    def handle_unknown_action
      @send_response_message.call(text: I18n.t("slack.response.action.unknown.acknowledgement"))
    end

    def handle_quest_complete(action)
      HistoricalMatch.find(action["value"].to_i).complete!(@user["id"])
      @send_response_message.call(text: I18n.t("slack.response.action.quest_complete.acknowledgement"))
      @send_response_message.call(text: I18n.t("slack.response.action.quest_complete.message.body"), type: "in_channel")
    end

    def handle_quest_continue(action)
      HistoricalMatch.find(action["value"].to_i).protract!(@user["id"])
      @send_response_message.call(text: I18n.t("slack.response.action.quest_continue.acknowledgement"))
      @send_response_message.call(text: I18n.t("slack.response.action.quest_continue.message.body"), type: "in_channel")
    end
  end
end
