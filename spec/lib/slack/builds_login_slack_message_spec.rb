require "rails_helper"

RSpec.describe Slack::BuildsLoginSlackMessage do
  let(:subject) { Slack::BuildsLoginSlackMessage.new }

  it "renders message as blocks" do
    user = User.create(slack_user_id: "USER", auth_token: "12345", auth_token_expires_at: 1.minute.from_now)

    content = subject.render(user: user)

    expect(content).to eq([
      {type: "section", text: {type: "mrkdwn", text: <<~MSG.chomp}}
        Use <http://example.com/auth/verify?token=12345|this link> to login.
      MSG
    ])
  end
end
