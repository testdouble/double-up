require "test_helper"

class ProtractedMatchTest < ActiveSupport::TestCase
  setup do
    @subject = ProtractedMatch
  end

  test "requires historical_match association" do
    match = @subject.new
    assert match.invalid?
    assert_equal match.errors[:historical_match].first, "must exist"
  end

  test "requires completed_at if completed_by is set" do
    match = @subject.new(completed_by: "Sam")
    assert match.invalid?
    assert_equal match.errors[:completed_at].first, "can't be blank"
  end

  test "requires completed_by if completed_at is set" do
    match = @subject.new(completed_at: Time.now)
    assert match.invalid?
    assert_equal match.errors[:completed_by].first, "can't be blank"
  end

  test "creates successfully" do
    match = create_historical_match(
      grouping: "test",
      members: ["Frodo", "Sam"]
    )

    protracted_match = @subject.new(historical_match: match)

    assert protracted_match.valid?
    assert protracted_match.errors.empty?
  end

  test "#complete_as! sets completed_by and completed_at" do
    match = create_historical_match(
      grouping: "test",
      members: ["Frodo", "Sam"]
    )

    protracted_match = @subject.create!(historical_match: match)

    Timecop.freeze(Time.zone.now) do
      protracted_match.complete_as!("Frodo")

      assert_equal protracted_match.completed_by, "Frodo"
      assert_not_nil protracted_match.completed_at
    end
  end
end
