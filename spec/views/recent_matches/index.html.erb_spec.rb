require "rails_helper"

RSpec.describe "recent_matches/index" do
  it "displays all the recent matches" do
    older_match = RecentMatch.new(
      match_id: 1,
      slack_user_id: "HOLMES",
      grouping: "test_group",
      matched_on: Date.civil(2022, 12, 31),
      other_members: [
        SlackUserProfile.new(slack_user_id: "WATSON", name: "John Watson", avatar_url: "https://example.com/x/512/512")
      ],
      match_status: "scoreable"
    )
    newer_match = RecentMatch.new(
      match_id: 1,
      slack_user_id: "HOLMES",
      grouping: "test_group",
      matched_on: Date.civil(2023, 2, 1),
      other_members: [
        SlackUserProfile.new(slack_user_id: "WATSON", name: "John Watson", avatar_url: "https://example.com/x/512/512"),
        SlackUserProfile.new(slack_user_id: "LESTRADE", name: "Greg Lestrade", avatar_url: "https://example.com/y/512/512")
      ],
      match_status: "scoreable"
    )
    assign(:recent_matches, [newer_match, older_match])

    render

    expect(rendered).to match(/Your recent matches/)
    expect(rendered).to match(/John Watson/)
    expect(rendered).to match(/Greg Lestrade/)
  end

  it "displays a message when no matches are given" do
    assign(:recent_matches, [])

    render

    expect(rendered).to match(/Your recent matches/)
    expect(rendered).to match(/No matches found yet/)
  end
end
