module Matchmaking
  class EstablishMatchesForGroup
    def initialize
      @loads_slack_channels = Slack::LoadsSlackChannels.new
      @loads_slack_channel_members = Slack::LoadsSlackChannelMembers.new
      @match_participants = Matchmaking::MatchParticipants.new
    end

    def call(group)
      ensure_channel_configured(group)

      channel = fetch_slack_channel(group.slack_channel_name)
      ensure_channel_found(channel, group)

      participants = collect_participants(group, channel.id)

      matches = @match_participants.call(participants, group)
      matches.each do |match|
        HistoricalMatch.create(
          members: match,
          grouping: group.name,
          matched_on: Date.today,
          pending_notifications: [
            PendingNotification.create(strategy: "email", reason: "new_match"),
            PendingNotification.create(strategy: "slack", reason: "new_match")
          ]
        )
      end

      protracted_matches(group).each do |match|
        PendingNotification.create(
          historical_match: match,
          strategy: "slack",
          reason: "quest_protraction"
        )
      end
    rescue => e
      ReportsError.report(e)
    end

    private

    def ensure_channel_configured(group)
      raise Errors::NoConfiguredChannel.new(group.name) unless group.slack_channel_name
    end

    def ensure_channel_found(channel, group)
      raise Errors::ChannelNotFound.new(group.slack_channel_name, group.name) unless channel
    end

    def protracted_matches(group)
      @protracted_matches ||= HistoricalMatch.protracted_in(group.name)
    end

    def collect_participants(group, channel_id)
      participants = @loads_slack_channel_members.call(channel: channel_id)
      unavailable_participants = protracted_matches(group).flat_map(&:members)
      participants.difference(unavailable_participants)
    end

    def fetch_slack_channel(channel_name)
      @loads_slack_channels.call(types: "public_channel").find { |channel|
        channel.name_normalized == channel_name
      }
    end
  end
end
