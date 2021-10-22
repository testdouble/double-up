module Matchmaking
  class Participant < Struct.new(:person, :scored_matches, :grouped_historical_matches)
  end
end
