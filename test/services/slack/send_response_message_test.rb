require "test_helper"

module Slack
  class SendResponseMessageTest < ActiveSupport::TestCase
    setup do
      @response_url = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
      @subject = SendResponseMessage.new(@response_url)
    end

    test "sends an ephemeral response message to the response url" do
      text = "Thanks!"
      expected_body = {text: text}.to_json

      stub_request(:post, @response_url)
        .with(body: expected_body, headers: {"Content-Type" => "application/json"})
        .to_return(status: 200)

      response = @subject.call(text: text)
      assert_equal 200, response.status
    end
  end
end
