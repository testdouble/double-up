require "test_helper"

module Matchmaking
  module Strategies
    class ArrangeGroupsGeneticallyTest < ActiveSupport::TestCase
      setup do
        srand(98765)

        @subject = ArrangeGroupsGenetically
        @balance_groups = Mocktail.of_next(BalanceGroups)
        @scored_participants = {
          "Frodo" => {"Sam" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Sam" => {"Frodo" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Merry" => {"Frodo" => 0, "Sam" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Pippin" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Gandalf" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Pippin" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Aragorn" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Legolas" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Gimli" => 0, "Boromir" => 0, "Gollum" => 0},
          "Gimli" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Boromir" => 0, "Gollum" => 0},
          "Boromir" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Gollum" => 0},
          "Gollum" => {"Frodo" => 0, "Sam" => 0, "Merry" => 0, "Pippin" => 0, "Gandalf" => 0, "Aragorn" => 0, "Legolas" => 0, "Gimli" => 0, "Boromir" => 0}
        }
      end

      test "matchmaking genetic algorithm" do
        stubs { |m| @balance_groups.call(m.any, 3) }.with do |call|
          (a, b, c, d, e, f, g, h, i, j) = call.args.first
          [[a, e, i], [b, f, j], [c, g], [d, h]]
        end

        strategy = @subject.new(target_group_size: 3, population_size: 50)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches.size, 4
        assert_equal matches.map(&:size), [3, 3, 2, 2]
        assert_equal matches.flatten.uniq.size, 10
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

      test "matchmaking with strict group size" do
        stubs { |m| @balance_groups.call(m.that { |a| a.size == 9 }, 3) }.with do |call|
          (a, b, c, d, e, f, g, h, i) = call.args.first
          [[a, d, g], [b, e, h], [c, f, i]]
        end

        strategy = @subject.new(target_group_size: 3, population_size: 50, strict_group_size: true)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches.size, 3
        assert_equal matches.map(&:size), [3, 3, 3]
        assert_equal matches.flatten.uniq.size, 9
      end
    end
  end
end
