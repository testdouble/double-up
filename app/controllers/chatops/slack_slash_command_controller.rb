module Chatops
  class SlackSlashCommandController < ::ApplicationChatopsController
    def handle
      command = SlackSlashCommand.new(**slack_command_params)

      response = HandlesSlashCommand.new.call(command)

      render plain: response
    end

    private

    def slack_command_params
      params.permit(:channel_name, :user_id, :text)
    end
  end
end
