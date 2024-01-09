class EstablishMatchesForGroupingJob
  def initialize(config: nil)
    @loads_slack_channels = Slack::LoadsSlackChannels.new
    @loads_slack_channel_members = Slack::LoadsSlackChannelMembers.new
    @match_participants = Matchmaking::MatchParticipants.new(config: config)

    @config = config || Rails.application.config.x.matchmaking
  end

  def perform(grouping:)
    channel = channel_for_grouping(grouping)

    participants = @loads_slack_channel_members.call(channel: channel.id)

    matches = @match_participants.call(participants, grouping)
    matches.each do |match|
      HistoricalMatch.create(
        members: match,
        grouping: grouping,
        matched_on: Date.today,
        pending_notifications: [
          PendingNotification.create(strategy: "email"),
          PendingNotification.create(strategy: "slack")
        ]
      )
    end
  rescue => e
    ReportsError.report(e)
  end

  private

  def channel_for_grouping(grouping)
    raise "No config found for grouping '#{grouping}'" unless @config.respond_to?(grouping.intern)

    channel_name = @config.send(grouping)&.channel
    raise "No configured channel for grouping '#{grouping}'" unless channel_name

    selected_channel = @loads_slack_channels.call(types: "public_channel").find { |channel|
      channel.name_normalized == channel_name
    }
    raise "No channel found with name '#{channel_name}' for grouping '#{grouping}'" unless selected_channel

    selected_channel
  end
end
