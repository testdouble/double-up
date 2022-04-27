module Slack
  class LoadsSlackChannelMembers
    def call(channel:)
      response = ClientWrapper.client.conversations_members(channel: channel, limit: 1000)

      (response&.members || []).intersection(eligible_user_ids)
    end

    private

    def eligible_user_ids
      response = ClientWrapper.client.users_list(limit: 200)
      members = get_paged_members(cursor: response&.response_metadata&.next_cursor, members: response&.members || [])

      (members || []).reject { |u| u.is_bot }.map(&:id)
    end

    def get_paged_members(cursor:, members:)
      while cursor.present?
        response = ClientWrapper.client.users_list(cursor: cursor, limit: 200)
        members.append(response.members)
        cursor = response.response_metadata&.next_cursor
      end

      members.flatten
    end
  end
end
