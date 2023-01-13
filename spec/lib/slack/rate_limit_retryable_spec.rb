require "rails_helper"

class RateLimitTester
  include Slack::RateLimitRetryable

  def run(&block)
    retry_when_rate_limited(max_retries: 2, &block)
  end
end

RSpec.describe Slack::RateLimitRetryable do
  let(:slack_request) { spy("slack request") }
  let(:too_many_requests_error) {
    Slack::Web::Api::Errors::TooManyRequestsError.new(Struct.new(:headers).new({"retry-after" => "1"}))
  }

  it "runs the code without needing a retry" do
    RateLimitTester.new.run { slack_request.call }

    expect(slack_request).to have_received(:call).once
  end

  it "retries after a rate limit failure is encountered" do
    rate_limit_hit = true

    RateLimitTester.new.run do
      slack_request.call

      if rate_limit_hit
        rate_limit_hit = false
        raise too_many_requests_error
      end
    end

    expect(slack_request).to have_received(:call).twice
  end

  it "does not retry for a non-rate-limit error" do
    error = Exception.new("test")

    expect {
      RateLimitTester.new.run { raise error }
    }.to raise_error(error)

    expect(slack_request).to_not have_received(:call)
  end

  it "does not retry when the retries have been exhausted" do
    expect {
      RateLimitTester.new.run do
        slack_request.call
        raise too_many_requests_error
      end
    }.to raise_error(too_many_requests_error)

    expect(slack_request).to have_received(:call).exactly(3).times
  end
end
