module Slack
  class OpensSlackConversation
    def call(users:)
      response = ClientWrapper.client.conversations_open(users: users.join(","))

      response&.channel&.id
    end
  end
end
