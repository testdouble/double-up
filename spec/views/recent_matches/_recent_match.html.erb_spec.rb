require "rails_helper"

RSpec.describe "rendering a recent match partial" do
  it "displays the recent match with 1 other member" do
    match = RecentMatch.new(
      match_id: 1,
      slack_user_id: "HOLMES",
      grouping: "test_group",
      matched_on: Date.civil(2022, 12, 31),
      other_members: [
        SlackUserProfile.new(slack_user_id: "WATSON", name: "John Watson", avatar_url: "https://example.com/x/512/512")
      ],
      match_status: "scoreable"
    )

    render partial: "recent_matches/recent_match", locals: {recent_match: match}

    expect(rendered).to match(/John Watson/)
    expect(rendered).to match(/src="https:\/\/example.com\/x\/512\/512"/)
    expect(rendered).to match(/href="\/profile\/WATSON"/)
    expect(rendered).to match(/Test Group/)
    expect(rendered).to match(/Dec 31, 2022/)
    expect(rendered).to match(/Included during matchmaking/)
  end

  it "displays a match that has been archived" do
    match = RecentMatch.new(
      match_id: 1,
      slack_user_id: "HOLMES",
      grouping: "test_group",
      matched_on: Date.civil(2021, 6, 4),
      other_members: [
        SlackUserProfile.new(slack_user_id: "WATSON", name: "John Watson", avatar_url: "https://example.com/x/512/512")
      ],
      match_status: "archived"
    )

    render :partial => "recent_matches/recent_match", locals: {recent_match: match}

    expect(rendered).to match(/John Watson/)
    expect(rendered).to match(/src="https:\/\/example.com\/x\/512\/512"/)
    expect(rendered).to match(/href="\/profile\/WATSON"/)
    expect(rendered).to match(/Test Group/)
    expect(rendered).to match(/Jun 04, 2021/)
    expect(rendered).to_not match(/Included during matchmaking/)
  end
end