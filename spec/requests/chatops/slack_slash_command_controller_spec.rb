require "rails_helper"

RSpec.describe "SlackSlashCommandController", type: :request do
  let(:text_arg) { "ping" } # Default text in case text_arg isn't specified
  let(:request_params) {{
      "token" => slack_signing_secret,
      "team_id" => "T02PF6RHYSY",
      "team_domain" => "testdouble-hq",
      "channel_id" => "C02NYBB3VPH",
      "channel_name" => "rotating-coffee",
      "user_id" => "U02PRHH0XEV",
      "user_name" => "cliff.pruitt",
      "command" => "/doubleup",
      "text" => text_arg,
      "api_app_id" => "A02PD0DUE03",
      "is_enterprise_install" => "false",
      "response_url" =>
       "https://hooks.slack.com/commands/T02PF6RHYSY/2823421496992/0WC0HfWeGJpHetxmF8yUmawo",
      "trigger_id" => "2801968477828.2797229610916.883001cf5008d6d02fd58a3cf70f449e"
    }
  }

  let(:slack_signing_secret) { Slack::Events.config.signing_secret }
  let(:timestamp) { Time.zone.now.to_i }
  let(:request_body) { "token=#{slack_signing_secret}&team_id=T02PF6RHYSY&team_domain=testdouble-hq&channel_id=C02NYBB3VPH&channel_name=some-channel&user_id=U02PRHH0XEV&user_name=cliff.pruitt&command=%2Fdoubleup&text=#{text_arg}&api_app_id=A02PD0DUE03&is_enterprise_install=false&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FT02PF6RHYSY%2F2823421496992%2F0WC0HfWeGJpHetxmF8yUmawo&trigger_id=2801968477828.2797229610916.883001cf5008d6d02fd58a3cf70f449e" }
  let(:data) { ["v0", timestamp, request_body].join(":") }
  let(:mac) { OpenSSL::HMAC.hexdigest("SHA256", slack_signing_secret, data) }
  let(:signature) { "v0=#{mac}" }
  let(:request_headers) {{
    "X-Slack-Signature" => signature,
    "X-Slack-Request-Timestamp" => timestamp
  }}
  

  describe "when run with default command" do
    subject { post "/command/doubleup", params: request_params, headers: request_headers }

    it "responds with ping" do
      subject

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("pong")
    end
  end

  describe "when run with available command" do
    let(:text_arg) { "available" }

    subject { post "/command/doubleup", params: request_params, headers: request_headers }

    it "responds with available confirmation" do
      subject

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("available")
    end
  end
end
