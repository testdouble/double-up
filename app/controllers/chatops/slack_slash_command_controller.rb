module Chatops
  class SlackSlashCommandController < ::ApplicationChatopsController
    AVAILABLE = "available"
    UNAVAILABLE = "unavailable"

    def handle
      message = params[:text]
      slack_user_id = params[:user_id]
      slack_channel = params[:channel_name]

      case message
      when AVAILABLE
        create_availability(slack_channel: slack_channel, slack_user_id: slack_user_id,
          availability: AVAILABLE,
        )
        render plain: "available"
      when UNAVAILABLE
        render plain: "unavailable"
      else
        render plain: "pong"
      end
    end

    private

    def create_availability(slack_channel:, slack_user_id:, availability:)
      Matchmaking::StoresMemberAvailability.new.call(
        slack_channel: slack_channel,
        slack_user_id: slack_user_id,
        availability: availability,
      )
    end
  end
end
