module Matchmaking
  class ScoredMatchCandidate < Struct.new(:id, :score, keyword_init: true)
    def initialize(id:, score: 0)
      super
    end
  end
end
