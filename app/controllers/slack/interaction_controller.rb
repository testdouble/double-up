module Slack
  class InteractionController < SlashCommandController
    def handle
      if block_actions?
        Slack::HandleInteraction.new(payload).call
      end

      head :ok
    end

    private

    def payload
      @payload ||= JSON.parse(params[:payload])
    end

    def block_actions?
      payload["type"] == "block_actions"
    end
  end
end
