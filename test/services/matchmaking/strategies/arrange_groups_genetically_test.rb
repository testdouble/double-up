module Matchmaking
  module Strategies
    class ArrangeGroupsGeneticallyTest < Minitest::Test
      def setup
        srand(98765)

        @subject = ArrangeGroupsGenetically
        @scored_participants = {
          "Frodo" => {"Pippin" => 0, "Merry" => 1, "Sam" => 2, "Gandalf" => 1},
          "Sam" => {"Frodo" => 2, "Pippin" => 1, "Merry" => 0, "Gandalf" => 0},
          "Pippin" => {"Frodo" => 0, "Merry" => 2, "Sam" => 1, "Gandalf" => 3},
          "Merry" => {"Frodo" => 1, "Pippin" => 2, "Sam" => 0, "Gandalf" => 2},
          "Gandalf" => {"Frodo" => 1, "Pippin" => 3, "Merry" => 2, "Sam" => 0}
        }
      end

      def test_matchmaking_groups
        strategy = @subject.new(target_group_size: 3, population_size: 50)

        matches = strategy.call(@scored_participants)

        assert matches.is_a?(Array)
        assert_equal matches, [["Pippin", "Frodo"], ["Gandalf", "Merry", "Sam"]]
      end

      def test_matchmaking_pairs_for_no_participants
        strategy = @subject.new(target_group_size: 3)

        matches = strategy.call({})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end

      def test_matchmaking_pairs_for_one_participant
        strategy = @subject.new(target_group_size: 3)

        matches = strategy.call({"Frodo" => {}})

        assert matches.is_a?(Array)
        assert_equal matches, []
      end
    end
  end
end
