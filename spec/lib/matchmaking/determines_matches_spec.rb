require "rails_helper"

RSpec.describe Matchmaking::DeterminesMatches, type: :matchmaking do
  let(:seed) { 98765 }

  before(:example) { srand(seed) }

  context "with a group size of 2" do
    let(:config) { OpenStruct.new(test: OpenStruct.new(size: 2)) }

    subject { Matchmaking::DeterminesMatches.new(config: config) }

    it "returns empty list for no participants" do
      matches = subject.call(grouping: "test", participants: [])

      expect(matches).to eq([])
    end

    it "returns empty list for a single participant" do
      participants = new_participants(ids: ["USER_ID_1"])

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([])
    end

    it "returns a single match when only two participants are given" do
      participants = new_participants(ids: ["USER_ID_1", "USER_ID_2"])

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_2"])
      ])
    end

    it "returns a larger match than desired when the number of participants does not divide cleanly" do
      participants = new_participants(ids: ["USER_ID_1", "USER_ID_2", "USER_ID_3"])

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_2", "USER_ID_3"])
      ])
    end

    it "returns multiple groups for a number of participants greater than minimum group size" do
      participants = new_participants(ids: ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4"])

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_2", "USER_ID_4"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_3"])
      ])
    end

    it "matches lower scored candidates over higher scored candidates" do
      one_and_two = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_2"])
      one_and_three = create_historical_match(grouping: "test", members: ["USER_ID_1", "USER_ID_3"])
      two_and_four = create_historical_match(grouping: "test", members: ["USER_ID_2", "USER_ID_4"])

      participants = [
        new_participant(
          id: "USER_ID_1",
          match_candidates: [
            new_match_candidate(id: "USER_ID_2", score: 1),
            new_match_candidate(id: "USER_ID_3", score: 1),
            new_match_candidate(id: "USER_ID_4")
          ],
          historical_matches: [one_and_two, one_and_three]
        ),
        new_participant(
          id: "USER_ID_2",
          match_candidates: [
            new_match_candidate(id: "USER_ID_1", score: 1),
            new_match_candidate(id: "USER_ID_3"),
            new_match_candidate(id: "USER_ID_4", score: 1)
          ],
          historical_matches: [one_and_two, two_and_four]
        ),
        new_participant(
          id: "USER_ID_3",
          match_candidates: [
            new_match_candidate(id: "USER_ID_1", score: 1),
            new_match_candidate(id: "USER_ID_2"),
            new_match_candidate(id: "USER_ID_4")
          ],
          historical_matches: [one_and_three]
        ),
        new_participant(
          id: "USER_ID_4",
          match_candidates: [
            new_match_candidate(id: "USER_ID_1"),
            new_match_candidate(id: "USER_ID_2", score: 1),
            new_match_candidate(id: "USER_ID_3")
          ],
          historical_matches: [two_and_four]
        )
      ]

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_2", "USER_ID_3"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_4"])
      ])
    end
  end

  context "with a group size of 3" do
    let(:config) { OpenStruct.new(test: OpenStruct.new(size: 3)) }

    subject { Matchmaking::DeterminesMatches.new(config: config) }

    it "returns single larger group when multiple cannot satisfy minimum group size" do
      participants = new_participants(ids: ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"])

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5"])
      ])
    end

    it "returns multiple groups of the desired size when enough participants exist" do
      participants = new_participants(
        ids: ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5", "USER_ID_6"]
      )

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_5", "USER_ID_6"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_2", "USER_ID_3", "USER_ID_4"])
      ])
    end

    it "returns multiple groups of difference sizes when enough participants exist" do
      participants = new_participants(
        ids: ["USER_ID_1", "USER_ID_2", "USER_ID_3", "USER_ID_4", "USER_ID_5", "USER_ID_6", "USER_ID_7"]
      )

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_3", "USER_ID_5", "USER_ID_6", "USER_ID_7"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_1", "USER_ID_2", "USER_ID_4"])
      ])
    end

    it "ensures all participants are matched exactly once on the first run" do
      participants = new_participants(
        ids: ["USER_ID_01", "USER_ID_02", "USER_ID_03", "USER_ID_04", "USER_ID_05", "USER_ID_06", "USER_ID_07", "USER_ID_08", "USER_ID_09", "USER_ID_10"]
      )

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches.map(&:members).flatten.uniq.size).to eq(10)
      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_05", "USER_ID_06", "USER_ID_08", "USER_ID_09"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_03", "USER_ID_04", "USER_ID_10"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_01", "USER_ID_02", "USER_ID_07"])
      ])
    end

    it "ensures all participants are matched exactly once on a subsequent run when historical matches exist" do
      five_six_eight_nine = create_historical_match(grouping: "test", members: ["USER_ID_05", "USER_ID_06", "USER_ID_08", "USER_ID_09"])
      three_four_ten = create_historical_match(grouping: "test", members: ["USER_ID_03", "USER_ID_04", "USER_ID_10"])
      one_two_seven = create_historical_match(grouping: "test", members: ["USER_ID_01", "USER_ID_02", "USER_ID_07"])

      participants = [
        new_participant(
          id: "USER_ID_01",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_03", "USER_ID_04", "USER_ID_05", "USER_ID_06", "USER_ID_08", "USER_ID_09", "USER_ID_10"],
            1 => ["USER_ID_02", "USER_ID_07"]
          }),
          historical_matches: [one_two_seven]
        ),
        new_participant(
          id: "USER_ID_02",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_03", "USER_ID_04", "USER_ID_05", "USER_ID_06", "USER_ID_08", "USER_ID_09", "USER_ID_10"],
            1 => ["USER_ID_01", "USER_ID_07"]
          }),
          historical_matches: [one_two_seven]
        ),
        new_participant(
          id: "USER_ID_03",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_05", "USER_ID_06", "USER_ID_07", "USER_ID_08", "USER_ID_09"],
            1 => ["USER_ID_04", "USER_ID_10"]
          }),
          historical_matches: [three_four_ten]
        ),
        new_participant(
          id: "USER_ID_04",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_05", "USER_ID_06", "USER_ID_07", "USER_ID_08", "USER_ID_09"],
            1 => ["USER_ID_03", "USER_ID_10"]
          }),
          historical_matches: [three_four_ten]
        ),
        new_participant(
          id: "USER_ID_05",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_03", "USER_ID_04", "USER_ID_07", "USER_ID_10"],
            1 => ["USER_ID_06", "USER_ID_08", "USER_ID_09"]
          }),
          historical_matches: [five_six_eight_nine]
        ),
        new_participant(
          id: "USER_ID_06",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_03", "USER_ID_04", "USER_ID_07", "USER_ID_10"],
            1 => ["USER_ID_05", "USER_ID_08", "USER_ID_09"]
          }),
          historical_matches: [five_six_eight_nine]
        ),
        new_participant(
          id: "USER_ID_07",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_03", "USER_ID_04", "USER_ID_05", "USER_ID_06", "USER_ID_08", "USER_ID_09", "USER_ID_10"],
            1 => ["USER_ID_01", "USER_ID_02"]
          }),
          historical_matches: [one_two_seven]
        ),
        new_participant(
          id: "USER_ID_08",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_03", "USER_ID_04", "USER_ID_07", "USER_ID_10"],
            1 => ["USER_ID_05", "USER_ID_06", "USER_ID_09"]
          }),
          historical_matches: [five_six_eight_nine]
        ),
        new_participant(
          id: "USER_ID_09",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_03", "USER_ID_04", "USER_ID_07", "USER_ID_10"],
            1 => ["USER_ID_05", "USER_ID_06", "USER_ID_08"]
          }),
          historical_matches: [five_six_eight_nine]
        ),
        new_participant(
          id: "USER_ID_10",
          match_candidates: new_candidates_by_score({
            0 => ["USER_ID_01", "USER_ID_02", "USER_ID_05", "USER_ID_06", "USER_ID_07", "USER_ID_08", "USER_ID_09"],
            1 => ["USER_ID_03", "USER_ID_04"]
          }),
          historical_matches: [three_four_ten]
        )
      ]

      matches = subject.call(grouping: "test", participants: participants)

      expect(matches.map(&:members).flatten.uniq.size).to eq(10)
      expect(matches).to eq([
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_02", "USER_ID_06", "USER_ID_09", "USER_ID_10"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_01", "USER_ID_04", "USER_ID_05"]),
        Matchmaking::Match.new(grouping: "test", members: ["USER_ID_03", "USER_ID_07", "USER_ID_08"])
      ])
    end
  end
end
