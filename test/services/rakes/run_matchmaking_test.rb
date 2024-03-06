require "test_helper"

module Rakes
  class RunMatchmakingTest < ActiveSupport::TestCase
    setup do
      @subject = RunMatchmaking
      @establish_matches_for_group = Mocktail.of_next(Matchmaking::EstablishMatchesForGroup)
      @identifies_nearest_date = Mocktail.of_next(IdentifiesNearestDate)
      @collect_groups = Mocktail.of_next(CollectGroups)
      @jan_5 = Date.civil(2021, 1, 5)

      Timecop.freeze(@jan_5)
      Timecop.travel(@jan_5)
    end

    test "shows successful message" do
      groups = [
        group_with(name: "test1", slack_channel_name: "group-test1", target_size: 2, schedule: :daily),
        group_with(name: "test2", slack_channel_name: "group-test2", target_size: 3, schedule: :daily),
        group_with(name: "test3", slack_channel_name: "group-test3", target_size: 4, schedule: :daily)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs(times: 3) { @identifies_nearest_date.call("daily") }.with { @jan_5 }
      stubs(times: 3) { |m| @establish_matches_for_group.call(m.is_a?(MatchmakingGroup)) }

      @subject.new(stdout: stdout, stderr: stderr).call

      output = read_output!
      assert_match(/Starting matchmaking for 'test1'/, output)
      assert_match(/Starting matchmaking for 'test2'/, output)
      assert_match(/Starting matchmaking for 'test3'/, output)
      assert_match(/Matchmaking successfully completed/, output)
      assert_empty read_errors!
    end

    test "shows an error message" do
      groups = [
        group_with(name: "test", slack_channel_name: "group-test", target_size: 2, schedule: :daily)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @identifies_nearest_date.call("daily") }.with { @jan_5 }
      stubs { |m| @establish_matches_for_group.call(m.any) }.with { raise "test" }

      assert_raises("test") do
        @subject.new(stdout: stdout, stderr: stderr).call
      end

      output = read_output!
      errors = read_errors!
      assert_match(/Starting matchmaking for 'test'/, output)
      assert_match(/Failed to run matchmaking for 'test'/, errors)
    end

    test "shows inactive message" do
      groups = [
        group_with(name: "test", slack_channel_name: "group-test", target_size: 2, schedule: :daily, is_active: false)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @identifies_nearest_date.call("daily") }.with { @jan_5 }

      @subject.new(stdout: stdout, stderr: stderr).call

      output = read_output!
      assert_match(/Skipping matchmaking for 'test'/, output)
    end

    test "shows completed message on an unscheduled day" do
      groups = [
        group_with(name: "test", slack_channel_name: "group-test", target_size: 2, schedule: :weekly)
      ]

      stubs { @collect_groups.call }.with { groups }
      stubs { @identifies_nearest_date.call("weekly") }.with { Date.civil(2021, 1, 6) }

      @subject.new(stdout: stdout, stderr: stderr).call

      output = read_output!
      assert_no_match(/Starting matchmaking for 'test'/, output)
      assert_match(/Matchmaking successfully completed/, output)
    end
  end
end
