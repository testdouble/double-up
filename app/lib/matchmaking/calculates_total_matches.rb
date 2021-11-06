module Matchmaking
  class CalculatesTotalMatches
    def call(total_participants:, target_size:)
      return 0 if total_participants < 2 || target_size < 2
      return 1 if total_participants <= target_size

      return total_participants / target_size unless target_size > 2

      (total_participants / target_size.to_f).round
    end
  end
end
