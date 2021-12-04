module Chatops
  class SlackSlashCommandController < ::ApplicationChatopsController
    def create
      render plain: "pong"
    end
  end
end
