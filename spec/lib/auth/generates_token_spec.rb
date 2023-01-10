require "rails_helper"

RSpec::Matchers.define :be_a_token do |_expected|
  match do |actual|
    CGI.escape(actual) == actual && actual.match?(/^[a-zA-Z0-9\-_]{22}$/)
  end
end

RSpec.describe Auth::GeneratesToken do
  let(:subject) { Auth::GeneratesToken.new }

  it "generates token for user when the user's token is nil" do
    user = User.create(auth_token: nil, auth_token_expires_at: nil, slack_user_id: "MEM_1")

    result = subject.call(user)

    expect(result).to be_a_token
    expect(user.reload.auth_token).to eq(result)
    expect(user.reload.auth_token_expires_at).to be_within(1).of(Auth::GeneratesToken::TOKEN_LIFETIME.minutes.from_now)
  end

  it "generates token for user when the user's token is expired" do
    token = "a" * 22
    user = User.create(auth_token: token, auth_token_expires_at: 1.second.ago, slack_user_id: "MEM_1")

    result = subject.call(user)

    expect(result).to_not eq(token)
    expect(result).to be_a_token
    expect(user.reload.auth_token).to eq(result)
    expect(user.reload.auth_token_expires_at).to be_within(1).of(Auth::GeneratesToken::TOKEN_LIFETIME.minutes.from_now)
  end

  it "keeps a user's token if it is still active" do
    token = "b" * 22
    expiry = 1.minute.from_now
    user = User.create(auth_token: token, auth_token_expires_at: expiry, slack_user_id: "MEM_1")

    result = subject.call(user)

    expect(result).to eq(token)
    expect(user.reload.auth_token).to eq(result)
    expect(user.reload.auth_token_expires_at).to be_within(1).of(expiry)
  end
end
