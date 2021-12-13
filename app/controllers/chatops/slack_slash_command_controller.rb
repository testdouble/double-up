module Chatops
  class SlackSlashCommandController < ::ApplicationChatopsController
    def handle
      render plain: "pong"
    end
  end
end
