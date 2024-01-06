module Slack
  class LoadsSlackChannelMembers
    include RateLimitRetryable

    def call(channel:)
      response = retry_when_rate_limited do
        ClientWrapper.client.conversations_members(channel: channel, limit: 1000)
      end

      (response&.members || []).intersection(eligible_user_ids)
    end

    private

    def eligible_user_ids
      response = retry_when_rate_limited do
        ClientWrapper.client.users_list
      end

      (response&.members || []).reject { |u| u.is_bot }.map(&:id)
    end
  end
end
