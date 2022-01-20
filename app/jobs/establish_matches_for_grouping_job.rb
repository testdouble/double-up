class EstablishMatchesForGroupingJob
  def initialize(config: nil)
    @loads_slack_channels = Slack::LoadsSlackChannels.new
    @loads_slack_channel_members = Slack::LoadsSlackChannelMembers.new
    @notifies_grouping_members = NotifiesGroupingMembers.new
    @matches_participants = Matchmaking::MatchesParticipants.new(config: config)

    @config = config || Rails.application.config.x.matchmaking
  end

  def perform(grouping:)
    channel = channel_for_grouping(grouping)

    matches = @matches_participants.call(
      grouping: grouping,
      participant_ids: members_for_channel(channel, selected_by: Matchmaking::SelectsAvailableParticipants.new(grouping: grouping))
    )
    matches.each do |match|
      @notifies_grouping_members.call(
        grouping: grouping,
        members: match.members,
        channel_name: channel.name_normalized
      )

      HistoricalMatch.create(members: match.members, grouping: grouping, matched_on: Date.today)
    end
  rescue => e
    ReportsError.report(e)
  end

  private

  def members_for_channel(channel, selected_by:)
    participant_ids = @loads_slack_channel_members.call(channel: channel.id)

    selected_by.call(participant_ids)
  end

  def channel_for_grouping(grouping)
    grouping_sym = grouping.intern

    raise "No config found for grouping '#{grouping}'" unless @config.respond_to?(grouping_sym)

    channel_name = @config.send(grouping_sym)&.channel
    raise "No configured channel for grouping '#{grouping}'" unless channel_name

    @loads_slack_channels.call(types: "public_channel").find { |channel|
      channel.name_normalized == channel_name
    }
  end
end
