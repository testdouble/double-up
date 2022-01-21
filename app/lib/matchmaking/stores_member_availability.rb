module Matchmaking
  class StoresMemberAvailability

    def initialize(config: nil)
      @config = config || Rails.application.config.x.matchmaking
    end

    def call(slack_channel:, slack_user_id:, availability:)
      GroupingMemberAvailability.create(
        grouping: grouping_for_channel(slack_channel),
        member_id: slack_user_id,
        availability: availability
      )
    end

    private
    
    # NOTE: Consider extracting to utility class
    # This will also be used in Matchmaking::RemovesMemberAvailability
    def grouping_for_channel(slack_channel)
      grouping = @config.to_h.find do |grouping, settings|
        settings.channel == slack_channel
      end.first
    end
  end
end