require "rails_helper"

RSpec.describe CalendarLink, type: :model do
  it "requires a link url" do
    link = CalendarLink.create

    expect(link.valid?).to be false
    expect(link.errors[:link_url].first).to eq("can't be blank")
  end

  it "requires a link name" do
    link = CalendarLink.create

    expect(link.valid?).to be false
    expect(link.errors[:link_name].first).to eq("can't be blank")
  end
end
