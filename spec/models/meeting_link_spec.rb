require "rails_helper"

RSpec.describe MeetingLink, type: :model do
  it "requires a meeting link url" do
    link = MeetingLink.create

    expect(link.valid?).to be false
    expect(link.errors[:link_url].first).to eq("can't be blank")
  end

  it "requires a meeting link text" do
    link = MeetingLink.create

    expect(link.valid?).to be false
    expect(link.errors[:link_text].first).to eq("can't be blank")
  end
end