require "rails_helper"

RSpec.describe GroupingMemberAvailability, type: :model do
  it "requires grouping attribute" do
    availability = GroupingMemberAvailability.create

    expect(availability.valid?).to be false
    expect(availability.errors[:grouping].first).to eq("can't be blank")
  end

  it "requires member_id attribute" do
    availability = GroupingMemberAvailability.create

    expect(availability.valid?).to be false
    expect(availability.errors[:member_id].first).to eq("can't be blank")
  end

  it "must be created with valid availability" do
    expect {
      GroupingMemberAvailability.create(
        grouping: "test",
        member_id: "USER_1",
        availability: :bogus
      )
    }.to raise_error(ArgumentError)
  end

  it "creates successfully" do
    availability = GroupingMemberAvailability.create(
      grouping: "test",
      member_id: "USER_ID_1",
      availability: :unavailable
    )

    expect(availability.valid?).to be true
    expect(availability.errors).to be_empty
  end
end
