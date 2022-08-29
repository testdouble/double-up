module Rakes
  class RemovesOldMatches
    def call
      HistoricalMatch.older_than(3.months.ago).destroy_all
      PendingNotification.where(historical_match: nil).destroy_all
    end
  end
end
