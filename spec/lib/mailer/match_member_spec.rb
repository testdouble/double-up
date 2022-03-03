require "rails_helper"

RSpec.describe Mailer::MatchMember do
  it "creates a user from a slack user" do
    slack_user = Slack::Messages::Message.new(
      id: "USER_ID", profile: Slack::Messages::Message.new(
        real_name: "Eren Yeager",
        email: "eren.yeager@surveycorps.gov"
      )
    )

    user = Mailer::MatchMember.from_slack_user(slack_user)

    expect(user.to_h).to eq({
      name: "Eren Yeager",
      email: "eren.yeager@surveycorps.gov"
    })
  end
end
