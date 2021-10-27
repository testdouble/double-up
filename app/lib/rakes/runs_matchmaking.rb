module Rakes
  class RunsMatchmaking
    def initialize(stdout:, stderr:, config: nil)
      @stdout = stdout
      @stderr = stderr
      @config = config || Rails.application.config.x.matchmaking

      @identifies_nearest_date = IdentifiesNearestDate.new
    end

    def call
      @config.each_pair do |grouping, grouping_config|
        next unless should_run_today?(grouping_config.schedule)

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

    private

    def should_run_today?(schedule)
      @identifies_nearest_date.call(schedule).today?
    end
  end
end
