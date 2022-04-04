module Slack
  class RetrievesSlackUserInfo
    def call(user:)
      response = ClientWrapper.client.users_info(user: user)

      response&.user
    end
  end
end
