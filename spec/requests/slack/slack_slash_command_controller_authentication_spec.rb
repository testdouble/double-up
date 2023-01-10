require "rails_helper"

class HmacChatopsController < Slack::SlashCommandController
  def index
    render json: {is_ok: "Sure. Why not?"}
  end
end

RSpec.describe "Slack::SlashCommandController authentication", type: :request do
  before :all do
    TestOnlyRoutes.draw do
      post "/chatops/only-if-hmac-verified", to: "hmac_chatops#index"
    end
  end

  after :all do
    TestOnlyRoutes.clear!
  end

  scenario "denies without HMAC verification" do
    post "/chatops/only-if-hmac-verified"
    expect(response).to have_http_status(:unauthorized)
  end

  scenario "allows with HMAC verification" do
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
      "text=",
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
      "text" => "",
      "api_app_id" => "APP",
      "is_enterprise_install" => "false",
      "response_url" => "",
      "trigger_id" => ""
    }

    post "/chatops/only-if-hmac-verified",
      params: request_params,
      headers: request_headers

    expect(response).to have_http_status(:ok)
  end

  scenario "allows with HMAC verification" do
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
      "text=unknown-command",
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
      "text" => "unknown-command",
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
      "text" => "Unrecognized command"
    })
  end
end
