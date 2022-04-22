module DatabaseHelpers
  def create_historical_match(grouping:, members:)
    HistoricalMatch.create(grouping: grouping, members: members, matched_on: Date.today)
  end

  def create_grouping_member_availability(grouping:, member_id:, availability:)
    GroupingMemberAvailability.create(
      grouping: grouping,
      member_id: member_id,
      availability: availability
    )
  end
end
