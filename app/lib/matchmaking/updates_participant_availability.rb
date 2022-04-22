module Matchmaking
  class UpdatesParticipantAvailability
    def initialize(config: nil)
      @config = config || Rails.application.config.x.matchmaking
    end

    def call(slack_channel:, member_id:, availability:)
      grouping = slack_channel_to_grouping(slack_channel)
      raise ArgumentError.new("No matching grouping for channel '#{slack_channel}'") unless grouping
      raise ArgumentError.new("Unrecognized availability ''#{availability}") unless GroupingMemberAvailability.availabilities.has_key? availability

      existing_availability = GroupingMemberAvailability.find_by(grouping: grouping, member_id: member_id)

      if existing_availability
        existing_availability.update(availability: availability)
      elsif availability != "available"
        GroupingMemberAvailability.create(grouping: grouping, member_id: member_id, availability: availability)
      end
    end

    private

    def slack_channel_to_grouping(slack_channel)
      @config.to_h.find do |grouping, settings|
        settings[:channel] == slack_channel
      end&.first
    end
  end
end
