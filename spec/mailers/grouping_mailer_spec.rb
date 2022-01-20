require "rails_helper"

RSpec.describe GroupingMailer do
  before(:example) do
    GroupingMailer.deliveries.clear
  end

  it "creates encourage_match mailer" do
    email = GroupingMailer.encourage_match(
      recipient: Mailer::MatchMember.new(name: "Sherlock", email: "holmes@deduction.com"),
      other_members: [
        Mailer::MatchMember.new(name: "Watson", email: "watson@deduction.com")
      ]
    )

    expect { email.deliver_now }.to change { GroupingMailer.deliveries.count }.by(1)

    expect(email.to).to eq(["holmes@deduction.com"])
    expect(email.from).to eq(["doubot@testdouble.com"])
    expect(email.reply_to).to eq(["watson@deduction.com"])
    expect(email.subject).to eq("doing some work")
    expect(email.body.to_s).to eq(
      <<~BODY
        Howdy Sherlock,
        
        You've been matched up for grouping from the channel Slack channel!
        
        Find a time to meet, and have fun!
        
        - Double Up San

      BODY
    )
  end
end
