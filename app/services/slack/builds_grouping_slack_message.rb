module Slack
  class BuildsGroupingSlackMessage < ApplicationMessage
    def render(grouping:, members:, channel_name:)
      [
        slack_greeting(grouping, members, channel_name)
      ].compact.flatten(1)
    end

    private

    def slack_greeting(grouping, members, channel_name)
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text:
            if members.size == 2
              <<~MSG.chomp
                :wave: Hi #{humanizes_users_reference(members)}! You've been matched up for #{grouping.to_s.titleize} from ##{channel_name}! Find a time to meet, and have fun!

                Run `/doubleup login` and click on a member's name for this match to see if they have set a calendar link for scheduling.
              MSG
            else
              <<~MSG.chomp
                :wave: Hi #{humanizes_users_reference(members)}! You've been matched up for #{grouping.to_s.titleize} from ##{channel_name}! Find a time to meet, and have fun!
              MSG
            end
        }
      }
    end

    def humanizes_users_reference(users)
      mentions = users.map { |u| slack_mention(u) }
      if mentions.size > 2
        all_except_last = mentions.take(mentions.size - 1).join(", ")
        "#{all_except_last} and #{mentions.last}"
      else
        mentions.join(" and ")
      end
    end
  end
end
