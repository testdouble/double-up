module Slack
  class SendsSlackMessage
    include RateLimitRetryable

    def call(**kwargs)
      retry_when_rate_limited do
        ClientWrapper.client.chat_postMessage(kwargs)
      end
    end
  end
end
