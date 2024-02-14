module Matchmaking
  module Errors
    class NoConfiguredChannel < StandardError
      def initialize(group_name)
        super("No configured channel for grouping '#{group_name}'")
      end
    end
  end
end
