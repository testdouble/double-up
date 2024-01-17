module Rakes
  class RunsMatchmaking
    def initialize(stdout:, stderr:)
      @stdout = stdout
      @stderr = stderr

      @identifies_nearest_date = IdentifiesNearestDate.new
      @collect_groups = CollectGroups.new
      @establish_matches_for_grouping_job = EstablishMatchesForGroupingJob.new
    end

    def call
      @collect_groups.call.each_pair do |grouping, grouping_config|
        next unless should_run_today?(grouping_config.schedule)

        unless grouping_config.active
          @stdout.puts "Skipping matchmaking for '#{grouping}'"
          next
        end

        @stdout.puts "Starting matchmaking for '#{grouping}'"
        @establish_matches_for_grouping_job.perform(grouping: grouping)
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
