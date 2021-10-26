module DatabaseHelpers
  def create_historical_match(grouping:, members:)
    HistoricalMatch.create(grouping: grouping, members: members, matched_on: Date.today)
  end
end
