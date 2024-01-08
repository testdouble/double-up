require "test_helper"

module Matchmaking
  module Strategies
    class ArrangeGroupsGeneticallyTest < ActiveSupport::TestCase
      setup do
        srand(98765)

        @subject = ArrangeGroupsGenetically
        @balance_groups = Mocktail.of_next(BalanceGroups)
        @scored_participants = {
          "Frodo" => {"Pippin" => 0, "Merry" => 1, "Sam" => 2, "Gandalf" => 1},
          "Sam" => {"Frodo" => 2, "Pippin" => 1, "Merry" => 0, "Gandalf" => 0},
          "Pippin" => {"Frodo" => 0, "Merry" => 2, "Sam" => 1, "Gandalf" => 3},
          "Merry" => {"Frodo" => 1, "Pippin" => 2, "Sam" => 0, "Gandalf" => 2},
          "Gandalf" => {"Frodo" => 1, "Pippin" => 3, "Merry" => 2, "Sam" => 0}
        }
      end

      test "matchmaking genetic algorithm" do
        stubs { |m| @balance_groups.call(m.any, 3) }.with do |call|
          (a, b, c, d, e) = call.args.first
          [[a, c, e], [b, d]]
        end

        strategy = @subject.new(target_group_size: 3, population_size: 50)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches, [["Pippin", "Frodo"], ["Gandalf", "Merry", "Sam"]]
      end

      test "matchmaking for no participants" do
        strategy = @subject.new(target_group_size: 3)

        matches = strategy.call({})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end

      test "matchmaking for one participant" do
        strategy = @subject.new(target_group_size: 3)

        matches = strategy.call({"Frodo" => {}})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end
    end
  end
end
