module Slack
  class LoadsSlackChannelMembers
    def call(channel:)
      response = ClientWrapper.client.conversations_members(channel: channel, limit: 1000)

      (response&.members || []).intersection(eligible_user_ids)
    end

    private

    def eligible_user_ids
      response = ClientWrapper.client.users_list

      (response&.members || []).reject { |u| u.is_bot }.map(&:id)
    end
  end
end
