require "rails_helper"

RSpec.describe Auth::ValidatesLoginAttempt do
  let(:subject) { Auth::ValidatesLoginAttempt.new }

  it "is successful when a matching token is active" do
    user = User.create(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "MEM")

    result = subject.call("12345")

    expect(result.success?).to be true
    expect(result.user).to eq(user)
  end

  it "is not successful when a matching token is expired" do
    User.create(auth_token: "12345", auth_token_expires_at: 1.minute.ago, slack_user_id: "MEM")

    result = subject.call("12345")

    expect(result.success?).to be false
    expect(result.user).to be_nil
  end

  it "is not successful when no matching token is found" do
    User.create(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "MEM")

    result = subject.call("abcde")

    expect(result.success?).to be false
    expect(result.user).to be_nil
  end
end
