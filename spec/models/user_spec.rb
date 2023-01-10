require "rails_helper"

RSpec.describe User, type: :model do
  it "requires a slack_user_id" do
    user = User.create

    expect(user.valid?).to be false
    expect(user.errors[:slack_user_id].first).to eq("can't be blank")
  end

  it "creates successfully" do
    user = User.create(slack_user_id: "USER_ID_1")

    expect(user.valid?).to be true
    expect(user.errors).to be_empty
  end
end
