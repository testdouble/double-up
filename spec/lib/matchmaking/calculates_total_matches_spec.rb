require "rails_helper"

RSpec.describe Matchmaking::CalculatesTotalMatches, type: :matchmaking do
  subject { Matchmaking::CalculatesTotalMatches.new }

  [
    [2, 0, 0], #    match sizes => []
    [2, 1, 0], #    match sizes => []
    [2, 2, 1], #    match sizes => [2]
    [2, 3, 1], #    match sizes => [2]
    [2, 4, 2], #    match sizes => [2,2]
    [2, 5, 2], #    match sizes => [3,2]

    [3, 0, 0], #    match sizes => []
    [3, 1, 0], #    match sizes => []
    [3, 2, 1], #    match sizes => [2]
    [3, 3, 1], #    match sizes => [3]
    [3, 4, 1], #    match sizes => [4]
    [3, 5, 2], #    match sizes => [3,2]
    [3, 6, 2], #    match sizes => [3,3]
    [3, 7, 2], #    match sizes => [4,3]
    [3, 8, 3], #    match sizes => [3,3,2]
    [3, 9, 3], #    match sizes => [3,3,3]
    [3, 10, 3], #   match sizes => [4,3,3]

    [4, 0, 0], #    match sizes => []
    [4, 1, 0], #    match sizes => []
    [4, 2, 1], #    match sizes => [2]
    [4, 3, 1], #    match sizes => [3]
    [4, 4, 1], #    match sizes => [4]
    [4, 5, 1], #    match sizes => [5]
    [4, 6, 2], #    match sizes => [3,3]
    [4, 7, 2], #    match sizes => [4,3]
    [4, 8, 2], #    match sizes => [4,4]
    [4, 9, 2], #    match sizes => [5,4]
    [4, 10, 3], #   match sizes => [4,3,3]
    [4, 11, 3], #   match sizes => [4,4,3]
    [4, 12, 3], #   match sizes => [4,4,4]
    [4, 13, 3] #    match sizes => [5,4,4]
  ].each do |target_size, number_of_participants, expected_total_matches|
    it "returns #{expected_total_matches} as the total matches when there are #{number_of_participants} participants for a desired match size of #{target_size}" do
      total_matches = subject.call(total_participants: number_of_participants, target_size: target_size)

      expect(total_matches).to eq(expected_total_matches)
    end
  end
end
