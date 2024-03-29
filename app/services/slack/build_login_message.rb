module Slack
  class BuildLoginMessage
    include Rails.application.routes.url_helpers

    def call(user:)
      Slack::BlockKit.blocks do |b|
        b.section do |s|
          s.mrkdwn(text: message_text(user))
        end
      end
    end

    private

    def message_text(user)
      I18n.t("slack.message.login", link: verify_login_url(token: user.auth_token))
    end
  end
end
