module Matchmaking
  class Match < Struct.new(:grouping, :members, keyword_init: true)
  end
end
