module Slack
  class LoadsSlackChannelMembers
    def call(channel:)
      response = ClientWrapper.client.conversations_members(channel: channel)

      (response&.members || [])
    end
  end
end
