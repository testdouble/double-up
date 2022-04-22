module Matchmaking
  class SelectsAvailableParticipants
    def initialize(grouping:)
      @grouping = grouping
    end

    def call(participant_ids)
      participant_ids - unavailable_participants_for_grouping(@grouping)
    end

    private

    def unavailable_participants_for_grouping(grouping)
      GroupingMemberAvailability.unavailable.where(grouping: grouping).pluck(:member_id)
    end
  end
end
