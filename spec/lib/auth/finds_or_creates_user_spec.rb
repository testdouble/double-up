require "rails_helper"

RSpec.describe Auth::FindsOrCreatesUser do
  let(:subject) { Auth::FindsOrCreatesUser.new }

  it "returns existing user" do
    user = User.create!(slack_user_id: "SLACK_USER_ID")

    result = subject.call("SLACK_USER_ID")

    expect(result).to eq(user)
  end

  it "creates a new user when it does not exist" do
    expect { subject.call("SLACK_USER_ID") }
      .to change { User.find_by(slack_user_id: "SLACK_USER_ID") }.from(nil).to(User)
  end
end
