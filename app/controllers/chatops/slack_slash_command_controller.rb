module Chatops
  class SlackSlashCommandController < ::ApplicationChatopsController
    def handle

      # slack_request = Slack::Events::Request.new(request)
      text_params = params["text"]

      case text_params
      when "available"
        "returning available"
      when "unavailable"
        "returning unavailable"
      else
        render plain: "pong"
      end
    end

    private

    def create_availability(slack_channel:, slack_user_id:)
      GroupingMemberAvailability.create(

        member_id: slack_user_id,
        availability: :unavailable
      )
    end
  end
end
