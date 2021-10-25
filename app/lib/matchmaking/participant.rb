module Matchmaking
  class Participant < Struct.new(:id, :match_candidates, :grouped_historical_matches)
  end
end
