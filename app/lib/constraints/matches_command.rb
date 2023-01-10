module Constraints
  class MatchesCommand
    def initialize(command:)
      @command = command
    end

    def matches?(request)
      @command == request.params["text"]
    end
  end
end
