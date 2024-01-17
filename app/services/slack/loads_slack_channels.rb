module Slack
  class LoadsSlackChannels
    include RateLimitRetryable

    SLACK_CHANNEL_TYPES = [
      "public_channel",
      "private_channel",
      "mpim",
      "im"
    ].freeze

    def call(types:)
      response = retry_when_rate_limited do
        ClientWrapper.client.conversations_list(types: approved_types(types), limit: 1000)
      end

      (response&.channels || []).reject { |ch| ch.is_archived }
    end

    private

    def approved_types(types)
      types.split(",").select { |t| SLACK_CHANNEL_TYPES.include?(t) }.join(",")
    end
  end
end
