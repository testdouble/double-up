require "test_helper"

module Rakes
  class RunsMatchmakingTest < ActiveSupport::TestCase
    setup do
      @subject = RunsMatchmaking
      @establish_matches_for_grouping_job = Mocktail.of_next(EstablishMatchesForGroupingJob)
      @identifies_nearest_date = Mocktail.of_next(IdentifiesNearestDate)
      @collect_groups = Mocktail.of_next(CollectGroups)
      @jan_5 = Date.civil(2021, 1, 5)

      Timecop.freeze(@jan_5)
      Timecop.travel(@jan_5)
    end

    test "shows successful message" do
      config = matchmaking_config(
        test1: {active: true, size: 2, channel: "group-test1", schedule: :daily},
        test2: {active: true, size: 3, channel: "group-test2", schedule: :daily},
        test3: {active: true, size: 4, channel: "group-test3", schedule: :daily}
      )

      stubs { @collect_groups.call }.with { config }
      stubs(times: 3) { @identifies_nearest_date.call(:daily) }.with { @jan_5 }
      stubs { @establish_matches_for_grouping_job.perform(grouping: :test1) }
      stubs { @establish_matches_for_grouping_job.perform(grouping: :test2) }
      stubs { @establish_matches_for_grouping_job.perform(grouping: :test3) }

      @subject.new(stdout: stdout, stderr: stderr).call

      output = read_output!
      assert_match(/Starting matchmaking for 'test1'/, output)
      assert_match(/Starting matchmaking for 'test2'/, output)
      assert_match(/Starting matchmaking for 'test3'/, output)
      assert_match(/Matchmaking successfully completed/, output)
      assert_empty read_errors!
    end

    test "shows an error message" do
      config = matchmaking_config(test: {channel: "group-test", schedule: :daily})

      stubs { @collect_groups.call }.with { config }
      stubs { @identifies_nearest_date.call(:daily) }.with { @jan_5 }
      stubs { @establish_matches_for_grouping_job.perform(grouping: :test) }.with { raise "test" }

      assert_raises("test") do
        @subject.new(stdout: stdout, stderr: stderr).call
      end

      output = read_output!
      errors = read_errors!
      assert_match(/Starting matchmaking for 'test'/, output)
      assert_match(/Failed to run matchmaking for 'test'/, errors)
    end

    test "shows inactive message" do
      config = matchmaking_config(test: {active: false, channel: "group-test", schedule: :daily})

      stubs { @collect_groups.call }.with { config }
      stubs { @identifies_nearest_date.call(:daily) }.with { @jan_5 }

      @subject.new(stdout: stdout, stderr: stderr).call

      output = read_output!
      assert_match(/Skipping matchmaking for 'test'/, output)
    end

    test "shows completed message on an unscheduled day" do
      config = matchmaking_config(test: {channel: "group-test", schedule: :weekly})

      stubs { @collect_groups.call }.with { config }
      stubs { @identifies_nearest_date.call(:weekly) }.with { Date.civil(2021, 1, 6) }

      @subject.new(stdout: stdout, stderr: stderr).call

      output = read_output!
      assert_no_match(/Starting matchmaking for 'test'/, output)
      assert_match(/Matchmaking successfully completed/, output)
    end
  end
end
