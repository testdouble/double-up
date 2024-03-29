require "test_helper"

module Slack
  class LoginWithSlackCommandControllerTest < ActionDispatch::IntegrationTest
    setup do
      @send_login_link = Mocktail.of_next(Auth::SendLoginLink)
    end

    test "sends a login link to the user" do
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

      post "/command/handle", params: request_params, headers: request_headers

      assert_response :success
      assert_equal({"response_type" => "ephemeral", "text" => "Check your DMs for a link to login with"}, JSON.parse(response.body))
      verify { @send_login_link.call(slack_user_id: "USER") }
    end
  end
end
