module Slack
  class LoginWithSlackCommandController < SlashCommandController
    def handle
      Auth::SendsLoginLink.new.call(slack_user_id: params["user_id"])

      render json: {
        response_type: "ephemeral",
        text: "Check your DMs for a link to login with"
      }
    end
  end
end
