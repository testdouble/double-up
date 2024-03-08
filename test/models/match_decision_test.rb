require "test_helper"

class MatchDecisionTest < ActiveSupport::TestCase
  setup do
    @subject = MatchDecision
  end

  test "requires decision attribute" do
    decision = @subject.new
    assert decision.invalid?
    assert_equal decision.errors[:decision].first, "can't be blank"
  end

  test "requires decided_by attribute" do
    decision = @subject.new
    assert decision.invalid?
    assert_equal decision.errors[:decided_by].first, "can't be blank"
  end

  test "requires historical_match association" do
    decision = @subject.new
    assert decision.invalid?
    assert_equal decision.errors[:historical_match].first, "must exist"
  end

  test "creates successfully" do
    match = create_historical_match(
      grouping: "test",
      members: ["Frodo", "Sam"]
    )

    decision = @subject.new(
      decision: "protract",
      decided_by: "Sam",
      historical_match: match
    )

    assert decision.valid?
    assert decision.errors.empty?
  end
end
