require "rails_helper"

RSpec.describe Mailer::BuildsGroupingMailerMessage do
  let(:subject) { Mailer::BuildsGroupingMailerMessage.new }

  before(:example) do
    @retrieves_slack_user_info = double(Slack::RetrievesSlackUserInfo)

    allow(Slack::RetrievesSlackUserInfo).to receive(:new) { @retrieves_slack_user_info }
  end

  it "builds a mailer message for a grouping" do
    recipient = Mailer::MatchMember.new(
      email: "holmes@deduction.com",
      name: "Sherlock"
    )
    other_member = Mailer::MatchMember.new(
      email: "watson@deduction.com",
      name: "John Watson"
    )

    mailer = subject.render(
      recipient: recipient,
      grouping: "test_time",
      channel: "rotating-test",
      other_members: [other_member]
    )

    expect(mailer.to).to eq(["holmes@deduction.com"])
    expect(mailer.from).to eq(["doubot@testdouble.com"])
    expect(mailer.reply_to).to eq(["watson@deduction.com"])
    expect(mailer.subject).to eq("Test Time with John Watson")
    expect(mailer.body.to_s).to eq(
      <<~BODY
        Howdy Sherlock,
        
        You've been matched up for Test Time from the #rotating-test Slack channel!
        
        Find a time to meet, and have fun!
        
        - Double Up San

      BODY
    )
  end
end
