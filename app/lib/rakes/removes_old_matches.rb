module Rakes
  class RemovesOldMatches
    def call
      HistoricalMatch.older_than(3.months.ago).update_all(status: "archived")
      HistoricalMatch.older_than(2.years.ago).destroy_all
      PendingNotification.where(historical_match: nil).destroy_all
    end
  end
end
