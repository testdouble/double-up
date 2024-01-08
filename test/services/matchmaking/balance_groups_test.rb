require "test_helper"

module Matchmaking
  class BalanceGroupsTest < ActiveSupport::TestCase
    setup do
      @subject = BalanceGroups.new
      @participant_matrix = (0..11).map.with_index do |row, index|
        [index, (0..index - 1).map { |column| (65 + column).chr }]
      end
    end

    test "balance for groups with target size of 3" do
      distributions = {
        0 => [],
        1 => [],
        2 => [["A", "B"]],
        3 => [["A", "B", "C"]],
        4 => [["A", "C"], ["B", "D"]],
        5 => [["A", "C", "E"], ["B", "D"]],
        6 => [["A", "C", "E"], ["B", "D", "F"]],
        7 => [["A", "D", "G"], ["B", "E"], ["C", "F"]],
        8 => [["A", "D", "G"], ["B", "E", "H"], ["C", "F"]],
        9 => [["A", "D", "G"], ["B", "E", "H"], ["C", "F", "I"]],
        10 => [["A", "E", "I"], ["B", "F", "J"], ["C", "G"], ["D", "H"]],
        11 => [["A", "E", "I"], ["B", "F", "J"], ["C", "G", "K"], ["D", "H"]]
      }

      @participant_matrix.each do |(group_count, participants)|
        assert_equal distributions[group_count], @subject.call(participants, 3), "Failed for #{group_count} participants"
      end
    end

    test "balance for groups with target size of 4" do
      distributions = {
        0 => [],
        1 => [],
        2 => [["A", "B"]],
        3 => [["A", "B", "C"]],
        4 => [["A", "B", "C", "D"]],
        5 => [["A", "C", "E"], ["B", "D"]],
        6 => [["A", "C", "E"], ["B", "D", "F"]],
        7 => [["A", "C", "E", "G"], ["B", "D", "F"]],
        8 => [["A", "C", "E", "G"], ["B", "D", "F", "H"]],
        9 => [["A", "D", "G"], ["B", "E", "H"], ["C", "F", "I"]],
        10 => [["A", "D", "G", "J"], ["B", "E", "H"], ["C", "F", "I"]],
        11 => [["A", "D", "G", "J"], ["B", "E", "H", "K"], ["C", "F", "I"]]
      }

      @participant_matrix.each do |(group_count, participants)|
        assert_equal distributions[group_count], @subject.call(participants, 4), "Failed for #{group_count} participants"
      end
    end

    test "balance for groups with target size of 5" do
      distributions = {
        0 => [],
        1 => [],
        2 => [["A", "B"]],
        3 => [["A", "B", "C"]],
        4 => [["A", "B", "C", "D"]],
        5 => [["A", "B", "C", "D", "E"]],
        6 => [["A", "C", "E"], ["B", "D", "F"]],
        7 => [["A", "C", "E", "G"], ["B", "D", "F"]],
        8 => [["A", "C", "E", "G"], ["B", "D", "F", "H"]],
        9 => [["A", "C", "E", "G", "I"], ["B", "D", "F", "H"]],
        10 => [["A", "C", "E", "G", "I"], ["B", "D", "F", "H", "J"]],
        11 => [["A", "D", "G", "J"], ["B", "E", "H", "K"], ["C", "F", "I"]]
      }

      @participant_matrix.each do |(group_count, participants)|
        assert_equal distributions[group_count], @subject.call(participants, 5), "Failed for #{group_count} participants"
      end
    end
  end
end
