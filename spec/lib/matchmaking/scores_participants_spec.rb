require "rails_helper"

RSpec.describe Matchmaking::ScoresParticipants do
  subject { Matchmaking::ScoresParticipants.new }

  it "scores nothing for no participants" do
    participants = []

    scores = subject.call(participants: participants)

    expect(scores).to eq([])
  end

  it "does not increase score for a single participant with no scored or historical matches" do
    participants = [
      Matchmaking::Participant.new("USER_ID_1", [], {})
    ]

    scores = subject.call(participants: participants)

    expect(scores).to eq(participants)
  end

  it "does not increase score for participants with no historical matches" do
    participants = [
      Matchmaking::Participant.new("USER_ID_1", [Matchmaking::ScoredMatch.new("USER_ID_2", 0)], {}),
      Matchmaking::Participant.new("USER_ID_2", [Matchmaking::ScoredMatch.new("USER_ID_1", 0)], {})
    ]

    scores = subject.call(participants: participants)

    expect(scores).to eq(participants)
  end

  it "increases scores for participants with a historical match" do
    one_and_three = HistoricalMatch.create(matches: ["USER_ID_1", "USER_ID_3"], grouping: "test")

    participants = [
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatch.new("USER_ID_2", 0),
        Matchmaking::ScoredMatch.new("USER_ID_3", 0)
      ], {
        "test" => [one_and_three]
      }),
      Matchmaking::Participant.new("USER_ID_2", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 0),
        Matchmaking::ScoredMatch.new("USER_ID_3", 0)
      ], {}),
      Matchmaking::Participant.new("USER_ID_3", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 0),
        Matchmaking::ScoredMatch.new("USER_ID_2", 0)
      ], {
        "test" => [one_and_three]
      })
    ]

    scores = subject.call(participants: participants)

    expect(scores[0]).to eq(
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatch.new("USER_ID_2", 0),
        Matchmaking::ScoredMatch.new("USER_ID_3", 1)
      ], {
        "test" => [one_and_three]
      })
    )
    expect(scores[1]).to eq(
      Matchmaking::Participant.new("USER_ID_2", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 0),
        Matchmaking::ScoredMatch.new("USER_ID_3", 0)
      ], {})
    )
    expect(scores[2]).to eq(
      Matchmaking::Participant.new("USER_ID_3", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 1),
        Matchmaking::ScoredMatch.new("USER_ID_2", 0)
      ], {
        "test" => [one_and_three]
      })
    )
  end

  it "increases scores for participants with historical matches for multiple groups" do
    one_and_two_red = HistoricalMatch.create(matches: ["USER_ID_1", "USER_ID_2"], grouping: "red")
    two_and_three_blue = HistoricalMatch.create(matches: ["USER_ID_2", "USER_ID_3"], grouping: "blue")
    one_and_two_green = HistoricalMatch.create(matches: ["USER_ID_1", "USER_ID_2"], grouping: "green")

    participants = [
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatch.new("USER_ID_2", 0),
        Matchmaking::ScoredMatch.new("USER_ID_3", 0)
      ], {
        "red" => [one_and_two_red],
        "green" => [one_and_two_green]
      }),
      Matchmaking::Participant.new("USER_ID_2", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 0),
        Matchmaking::ScoredMatch.new("USER_ID_3", 0)
      ], {
        "red" => [one_and_two_red],
        "blue" => [two_and_three_blue],
        "green" => [one_and_two_green]
      }),
      Matchmaking::Participant.new("USER_ID_3", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 0),
        Matchmaking::ScoredMatch.new("USER_ID_2", 0)
      ], {
        "blue" => [two_and_three_blue]
      })
    ]

    scores = subject.call(participants: participants)

    expect(scores[0]).to eq(
      Matchmaking::Participant.new("USER_ID_1", [
        Matchmaking::ScoredMatch.new("USER_ID_2", 2),
        Matchmaking::ScoredMatch.new("USER_ID_3", 0)
      ], {
        "red" => [one_and_two_red],
        "green" => [one_and_two_green]
      })
    )
    expect(scores[1]).to eq(
      Matchmaking::Participant.new("USER_ID_2", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 2),
        Matchmaking::ScoredMatch.new("USER_ID_3", 1)
      ], {
        "red" => [one_and_two_red],
        "blue" => [two_and_three_blue],
        "green" => [one_and_two_green]
      })
    )
    expect(scores[2]).to eq(
      Matchmaking::Participant.new("USER_ID_3", [
        Matchmaking::ScoredMatch.new("USER_ID_1", 0),
        Matchmaking::ScoredMatch.new("USER_ID_2", 1)
      ], {
        "blue" => [two_and_three_blue]
      })
    )
  end
end
