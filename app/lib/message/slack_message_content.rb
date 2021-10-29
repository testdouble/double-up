module Message
  class SlackMessageContent
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::TextHelper

    def slack_divider
      {type: "divider"}
    end

    def slack_link(link, text)
      "<#{link}|#{text}>"
    end

    def slack_mention(user)
      "<@#{user}>"
    end
  end
end
