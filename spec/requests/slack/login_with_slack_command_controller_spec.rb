require "rails_helper"

RSpec.describe "LoginWithSlackCommandController", type: :request do
  before(:example) do
    allow_any_instance_of(Auth::SendsLoginLink).to receive(:call)
  end

  scenario "sends a link and responds with an ephemeral message" do
    slack_signing_secret = Slack::Events.config.signing_secret
    timestamp = Time.zone.now.to_i
    request_body = [
      "token=#{slack_signing_secret}",
      "team_id=TESTTEAM",
      "team_domain=test-team",
      "channel_id=CHANNEL",
      "channel_name=test-channel",
      "user_id=USER",
      "user_name=test.mctestface",
      "command=%2Fdoubleup",
      "text=login",
      "api_app_id=APP",
      "is_enterprise_install=false",
      "response_url=",
      "trigger_id="
    ].join("&")
    data = ["v0", timestamp, request_body].join(":")
    mac = OpenSSL::HMAC.hexdigest("SHA256", slack_signing_secret, data)
    signature = "v0=#{mac}"

    request_headers = {
      "X-Slack-Signature" => signature,
      "X-Slack-Request-Timestamp" => timestamp
    }

    request_params = {
      "token" => slack_signing_secret,
      "team_id" => "TESTTEAM",
      "team_domain" => "test-team",
      "channel_id" => "CHANNEL",
      "channel_name" => "test-channel",
      "user_id" => "USER",
      "user_name" => "test.mctestface",
      "command" => "/doubleup",
      "text" => "login",
      "api_app_id" => "APP",
      "is_enterprise_install" => "false",
      "response_url" => "",
      "trigger_id" => ""
    }

    post "/command/handle",
      params: request_params,
      headers: request_headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq({
      "response_type" => "ephemeral",
      "text" => "Check your DMs for a link to login with"
    })
  end
end
