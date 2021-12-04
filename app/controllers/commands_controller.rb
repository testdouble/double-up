class CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_slack_hmac

  def doubleup
    render json: {
      "blocks" => [
        {
          "type" => "section",
          "text" => {
            "type" => "mrkdwn",
            "text" => "You've been *__DOUBLE'D UP!__*"
          }
        },
        {
          "type" => "section",
          "text" => {
            "type" => "mrkdwn",
            "text" => "```
              #{params.to_yaml}
            ```"
          }
        }
      ]
    }
  end

  private

  def slack_signature
    request.headers["X-Slack-Signature"]
  end

  def slack_timestamp
    request.headers["X-Slack-Request-Timestamp"]
  end

  def verify_slack_hmac
    binding.pry #cpdebug
    slack_request = Slack::Events::Request.new(request)
    slack_request.verify!
  end

  def verify_hmac
    key = "cc8938263f4abecd7c36a46473d7b6a9"
    data = ["v0", slack_timestamp, request.body.string].join(":")
    mac = OpenSSL::HMAC.hexdigest("SHA256", key, data)
    puts key, data, mac
    "v0=#{mac}"
  end
end
