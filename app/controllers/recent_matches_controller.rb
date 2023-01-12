class RecentMatchesController < ApplicationController
  def show
    @historical_matches = HistoricalMatch.for_user(@current_user).order(matched_on: :desc)
  end
end
