require "rails_helper"

RSpec.describe Mailer::GroupingMailerParameters do
  it "creates initializes parameters for passing to the grouping mailer" do
    slack_user = Slack::Messages::Message.new(
      id: "USER_ID", profile: Slack::Messages::Message.new(
        real_name: "William Rose",
        email: "rose@gnr.com"
      )
    )
    grouping = "Jungle"
    channel = "fun-and-games"
    member = Mailer::MatchMember.from_slack_user(slack_user)

    params = Mailer::GroupingMailerParameters.new(
      other_members: [member],
      grouping: grouping,
      channel: channel
    )

    expect(params.to_h).to eq({
      channel: channel,
      grouping: grouping,
      other_members: [member]
    })
  end
end
