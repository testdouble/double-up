module Rakes
  class RunMatchmaking
    def initialize(stdout:, stderr:, only: nil)
      @stdout = stdout
      @stderr = stderr

      @only = only || []

      @identifies_nearest_date = IdentifiesNearestDate.new
      @collect_groups = CollectGroups.new
      @establish_matches_for_group = Matchmaking::EstablishMatchesForGroup.new
    end

    def call
      groups.each do |group|
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

    def groups
      @collect_groups.call.select { |group| @only.any? ? @only.include?(group.name) : true }
    end

    def should_run_today?(schedule)
      @identifies_nearest_date.call(schedule).today?
    end
  end
end
