module Slack
  class RetrievesSlackUserInfo
    include RateLimitRetryable

    def call(user:)
      response = retry_when_rate_limited do
        ClientWrapper.client.users_info(user: user)
      end

      response&.user
    end
  end
end
