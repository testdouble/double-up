module DatabaseTestHelper
  def create_historical_match(grouping:, members:, pending_notifications: [])
    HistoricalMatch.create(
      grouping: grouping,
      members: members,
      matched_on: Date.today,
      pending_notifications: pending_notifications
    )
  end
end
