module Rakes
  class RunsMatchmaking
    def initialize(stdout:, stderr:, config: nil)
      @stdout = stdout
      @stderr = stderr
      @config = config || Rails.application.config.x.matchmaking
    end

    def call
      @config.each_pair do |grouping, grouping_config|
        unless grouping_config.active
          @stdout.puts "Skipping matchmaking for '#{grouping}'"
          next
        end

        @stdout.puts "Starting matchmaking for '#{grouping}'"
        EstablishMatchesForGroupingJob.new.perform(grouping: grouping)
      rescue => e
        @stderr.puts "Failed to run matchmaking for '#{grouping}'. Reporting to Bugsnag."
        ReportsError.report(e)
      end
      @stdout.puts "Matchmaking successfully completed"
    end
  end
end
