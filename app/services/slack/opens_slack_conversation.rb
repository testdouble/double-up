module Slack
  class OpensSlackConversation
    include RateLimitRetryable

    def call(users:)
      response = retry_when_rate_limited do
        ClientWrapper.client.conversations_open(users: users.join(","))
      end

      response&.channel&.id
    end
  end
end
