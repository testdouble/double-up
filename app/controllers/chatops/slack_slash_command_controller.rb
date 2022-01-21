module Chatops
  class SlackSlashCommandController < ::ApplicationChatopsController
    def handle
      text_params = params["text"]

      case text_params
      when "available", "unavailable"
        Matchmaking::UpdatesParticipantAvailability.new.call(
          slack_channel: params["channel_name"],
          member_id: params["user_id"],
          availability: params["text"]
        )
        render plain: "Success"
      else
        render plain: "pong"
      end
    end
  end
end
