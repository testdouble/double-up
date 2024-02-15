module Matchmaking
  module Errors
    class ChannelNotFound < StandardError
      def initialize(group_name, channel_name)
        super("No channel found with name '#{channel_name}' for grouping '#{group_name}'")
      end
    end
  end
end
