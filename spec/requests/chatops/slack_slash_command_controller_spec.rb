require "rails_helper"

RSpec.describe Chatops::SlackSlashCommandController, type: :request do
  let(:text) { "anything" }
  let(:channel) { "rotating-test-channel" }
  let(:slack_signing_secret) { Slack::Events.config.signing_secret }
  let(:timestamp) { Time.zone.now.to_i }
  let(:request_body) { "token=#{slack_signing_secret}&team_id=T02PF6RHYSY&team_domain=testdouble-hq&channel_id=C02NYBB3VPH&channel_name=#{channel}&user_id=U02PRHH0XEV&user_name=cliff.pruitt&command=%2Fdoubleup&text=#{text}&api_app_id=A02PD0DUE03&is_enterprise_install=false&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FT02PF6RHYSY%2F2823421496992%2F0WC0HfWeGJpHetxmF8yUmawo&trigger_id=2801968477828.2797229610916.883001cf5008d6d02fd58a3cf70f449e" }
  let(:data) { ["v0", timestamp, request_body].join(":") }
  let(:mac) { OpenSSL::HMAC.hexdigest("SHA256", slack_signing_secret, data) }
  let(:signature) { "v0=#{mac}" }

  let(:request_headers) do
    {
      "X-Slack-Signature" => signature,
      "X-Slack-Request-Timestamp" => timestamp
    }
  end

  let(:request_params) do
    {
      "token" => slack_signing_secret,
      "team_id" => "T02PF6RHYSY",
      "team_domain" => "testdouble-hq",
      "channel_id" => "C02NYBB3VPH",
      "channel_name" => channel,
      "user_id" => "U02PRHH0XEV",
      "user_name" => "cliff.pruitt",
      "command" => "/doubleup",
      "text" => text,
      "api_app_id" => "A02PD0DUE03",
      "is_enterprise_install" => "false",
      "response_url" =>
        "https://hooks.slack.com/commands/T02PF6RHYSY/2823421496992/0WC0HfWeGJpHetxmF8yUmawo",
      "trigger_id" => "2801968477828.2797229610916.883001cf5008d6d02fd58a3cf70f449e"
    }
  end

  before(:example) do
    @handles_slash_command = double(Chatops::HandlesSlashCommand)
    allow(Chatops::HandlesSlashCommand).to receive(:new) { @handles_slash_command }
  end

  describe "user asks to be unavailable" do
    let(:text) { "unavailable" }

    subject { post "/command/doubleup", params: request_params, headers: request_headers }

    it "responds to `/doubleup unavailable`" do
      expect(@handles_slash_command).to receive(:call) { "Success" }
      subject

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("Success")
    end
  end

  describe "user asks to be available" do
    let(:text) { "available" }

    subject { post "/command/doubleup", params: request_params, headers: request_headers }

    it "responds to available when user is already available" do
      expect(@handles_slash_command).to receive(:call) { "Success" }
      subject

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("Success")
    end

    it "responds to available when user is unavailable" do
      expect(@handles_slash_command).to receive(:call) { "Success" }
      subject

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("Success")
    end
  end

  describe "any other text command is given" do
    let(:text) { "ping" }

    subject { post "/command/doubleup", params: request_params, headers: request_headers }

    it "responds to anything with pong" do
      expect(@handles_slash_command).to receive(:call) { "pong" }
      subject

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("pong")
    end
  end
end
