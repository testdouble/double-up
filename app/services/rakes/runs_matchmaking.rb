module Rakes
  class RunsMatchmaking
    def initialize(stdout:, stderr:)
      @stdout = stdout
      @stderr = stderr

      @identifies_nearest_date = IdentifiesNearestDate.new
      @collect_groups = CollectGroups.new
      @establish_matches_for_group = Matchmaking::EstablishMatchesForGroup.new
    end

    def call
      @collect_groups.call.each do |group|
        next unless should_run_today?(group.schedule)

        unless group.active?
          @stdout.puts "Skipping matchmaking for '#{group.name}'"
          next
        end

        @stdout.puts "Starting matchmaking for '#{group.name}'"
        @establish_matches_for_group.call(group)
      rescue => e
        @stderr.puts "Failed to run matchmaking for '#{group.name}'. Reporting to Bugsnag."
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
