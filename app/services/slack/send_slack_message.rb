module Slack
  class SendSlackMessage
    include RateLimitRetryable

    def call(**kwargs)
      retry_when_rate_limited do
        if kwargs[:blocks].is_a?(Slack::BlockKit::Blocks)
          kwargs[:blocks] = kwargs[:blocks].to_json
        end

        ClientWrapper.client.chat_postMessage(kwargs)
      end
    end
  end
end
