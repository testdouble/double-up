module Slack
  class LoadsSlackChannels
    SLACK_CHANNEL_TYPES = [
      "public_channel",
      "private_channel",
      "mpim",
      "im"
    ].freeze

    def call(types:)
      response = ClientWrapper.client.conversations_list(types: approved_types(types))

      (response&.channels || []).reject { |ch| ch.is_archived }
    end

    private

    def approved_types(types)
      types.split(",").select { |t| SLACK_CHANNEL_TYPES.include?(t) }.join(",")
    end
  end
end
