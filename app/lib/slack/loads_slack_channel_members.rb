module Slack
  class LoadsSlackChannelMembers
    def call(channel:)
      response = ClientWrapper.client.conversations_members(channel: channel, limit: 1000)

      (response&.members || [])
    end
  end
end
