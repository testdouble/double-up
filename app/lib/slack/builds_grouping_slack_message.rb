module Slack
  class BuildsGroupingSlackMessage < ApplicationMessage
    def initialize(config: nil)
      @config = config || Rails.application.config.x.matchmaking
    end

    def render(match:)
      channel_name = channel_name_for_grouping(match.grouping)

      [
        slack_greeting(match.grouping, match.members, channel_name)
      ].compact.flatten(1)
    end

    private

    def channel_name_for_grouping(grouping)
      grouping_sym = grouping.intern

      raise "No config found for grouping '#{grouping}'" unless @config.respond_to?(grouping_sym)

      @config.send(grouping_sym)&.channel
    end

    def slack_greeting(grouping, members, channel_name)
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: <<~MSG.chomp
            :wave: Hi #{humanizes_users_reference(members)}! You've been matched up for #{grouping.to_s.titleize} from ##{channel_name}! Find a time to meet, and have fun!
          MSG
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
