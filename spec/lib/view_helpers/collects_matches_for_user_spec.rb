require "rails_helper"

RSpec.describe ViewHelpers::CollectsMatchesForUser do
  let(:subject) { ViewHelpers::CollectsMatchesForUser.new }

  before(:example) do
    @retrieves_slack_user_info = double(Slack::RetrievesSlackUserInfo)

    allow(Slack::RetrievesSlackUserInfo).to receive(:new) { @retrieves_slack_user_info }
  end

  it "merges matches and slack profile data from the database for match members" do
    user = User.create(slack_user_id: "USER_ID_1")
    match_date = Date.today
    SlackUserProfile.create(name: "Leia", slack_user_id: "USER_ID_2", avatar_url: "https://example.com/x/512/512")
    HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_2"], grouping: "test", matched_on: match_date)

    expect(@retrieves_slack_user_info).to_not receive(:call)

    user_matches = subject.call(user: user)

    expect(user_matches).to eq([
      ViewHelpers::UserMatch.new(
        slack_user_id: "USER_ID_1",
        grouping: "test",
        matched_on: match_date,
        other_members: [SlackUserProfile.find_by(slack_user_id: "USER_ID_2")],
        match_status: "scoreable"
      )
    ])
  end

  it "sorts the matches from most recent to oldest" do
    user = User.create(slack_user_id: "USER_ID_1")
    match_date = Date.today
    SlackUserProfile.create(name: "Leia", slack_user_id: "USER_ID_2", avatar_url: "https://example.com/x/512/512")
    HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_2"], grouping: "test", matched_on: match_date - 1.day)
    HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_2"], grouping: "test", matched_on: match_date)

    expect(@retrieves_slack_user_info).to_not receive(:call)

    user_matches = subject.call(user: user)

    expect(user_matches).to eq([
      ViewHelpers::UserMatch.new(
        slack_user_id: "USER_ID_1",
        grouping: "test",
        matched_on: match_date,
        other_members: [SlackUserProfile.find_by(slack_user_id: "USER_ID_2")],
        match_status: "scoreable"
      ),
      ViewHelpers::UserMatch.new(
        slack_user_id: "USER_ID_1",
        grouping: "test",
        matched_on: match_date - 1.day,
        other_members: [SlackUserProfile.find_by(slack_user_id: "USER_ID_2")],
        match_status: "scoreable"
      )
    ])
  end

  it "retrieves profile info from Slack when an existing profile wasn't found in the database" do
    user = User.create(slack_user_id: "USER_ID_1")
    match_date = Date.today
    HistoricalMatch.create(members: ["USER_ID_1", "USER_ID_2"], grouping: "test", matched_on: match_date)

    expect(@retrieves_slack_user_info).to receive(:call).with(user: "USER_ID_2")

    subject.call(user: user)
  end

  it "returns an empty array for a user with no matches" do
    user = User.create(slack_user_id: "USER_ID_1")

    user_matches = subject.call(user: user)

    expect(user_matches).to eq([])
  end
end
