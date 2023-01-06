module Slack
  class BuildsLoginSlackMessage < ApplicationMessage
    include Rails.application.routes.url_helpers

    def render(user:)
      [
        verify_message(user)
      ].compact.flatten(1)
    end

    private

    def login_link(user, text)
      link = verify_login_url(token: user.auth_token)
      # link = "https://1fa9-68-99-55-76.ngrok.io/auth/verify/#{user.auth_token}"

      "<#{link}|#{text}>"
    end

    def verify_message(user)
      verify_link = login_link(user, "this link")
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: <<~MSG.chomp
            Use #{verify_link} to login.
          MSG
        }
      }
    end
  end
end
