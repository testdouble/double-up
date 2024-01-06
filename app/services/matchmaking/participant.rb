module Matchmaking
  class Participant < Struct.new(:id, :match_candidates, :grouped_historical_matches, keyword_init: true)
  end
end
