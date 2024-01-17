module Slack
  module RateLimitRetryable
    def retry_when_rate_limited(max_retries: 3, &block)
      block.call
    rescue Slack::Web::Api::Errors::TooManyRequestsError => e
      raise e if max_retries.zero?

      sleep e.retry_after
      retry_when_rate_limited(max_retries: max_retries - 1, &block)
    end
  end
end
