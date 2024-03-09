require "test_helper"

class HistoricalMatchTest < ActiveSupport::TestCase
  setup do
    @subject = HistoricalMatch
  end

  test "requires at least two members" do
    match = @subject.new(members: ["Frodo"])
    assert match.invalid?
    assert_equal match.errors[:members].first, "must include multiple members"
  end

  test "requires matched_on attribute" do
    match = @subject.new
    assert match.invalid?
    assert_equal match.errors[:matched_on].first, "can't be blank"
  end

  test "requires grouping attribute" do
    match = @subject.new
    assert match.invalid?
    assert_equal match.errors[:grouping].first, "can't be blank"
  end

  test "creates successfully" do
    match = @subject.new(
      grouping: "test",
      members: ["Frodo", "Sam"],
      matched_on: Date.today
    )

    assert match.valid?
    assert match.errors.empty?
  end

  test "#in_grouping scope returns all records in the specified grouping" do
    @subject.create(
      grouping: "hobbits",
      matched_on: Date.today,
      members: ["Frodo", "Sam"]
    )

    @subject.create(
      grouping: "hobbits",
      matched_on: Date.today,
      members: ["Sam", "Pippin"]
    )

    @subject.create(
      grouping: "elves",
      matched_on: Date.today,
      members: ["Legolas", "Elrond"]
    )

    matches = @subject.in_grouping("hobbits")

    assert_equal matches.size, 2
    assert_equal matches.map(&:grouping).uniq, ["hobbits"]
  end

  test "#with_member scope returns all records with the given member" do
    match1 = @subject.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["Frodo", "Sam"]
    )

    @subject.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["Sam", "Pippin"]
    )

    match3 = @subject.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["Frodo", "Pippin"]
    )

    matches = @subject.with_member("Frodo")

    assert_equal matches.size, 2
    assert_equal matches, [match1, match3]
  end

  test "#older_than scope returns all records older than the specified date" do
    @subject.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["Frodo", "Sam"]
    )

    older_match = @subject.create(
      grouping: "test",
      matched_on: Date.today,
      members: ["Frodo", "Sam"],
      created_at: Date.today - 3.months
    )

    matches = @subject.older_than(Date.today)

    assert_equal matches, [older_match]
  end

  test "#for_user scope returns all records with the given user as a member" do
    match1, _, match3 = [
      @subject.create(
        grouping: "test",
        matched_on: Date.today,
        members: ["Frodo", "Sam"]
      ),
      @subject.create(
        grouping: "test",
        matched_on: Date.today,
        members: ["Sam", "Pippin"]
      ),
      @subject.create(
        grouping: "test",
        matched_on: Date.today,
        members: ["Frodo", "Pippin"]
      )
    ]

    user = User.new(slack_user_id: "Frodo")

    matches = @subject.for_user(user)

    assert_equal matches, [match1, match3]
  end

  test ".protracted_in returns the most recent protracted matches" do
    _match1, match2, _match3 = [
      @subject.create(
        grouping: "test",
        matched_on: Date.today,
        members: ["Frodo", "Sam"]
      ),
      @subject.create(
        grouping: "test",
        matched_on: Date.today,
        members: ["Sam", "Pippin"],
        protracted_match: ProtractedMatch.new(protracted_by: "Sam")
      ),
      @subject.create(
        grouping: "test",
        matched_on: Date.today,
        members: ["Sam", "Pippin"],
        protracted_match: ProtractedMatch.new(protracted_by: "Sam", completed_at: Time.zone.now, completed_by: "Pippin")
      )
    ]

    matches = @subject.protracted_in("test")

    assert_equal matches, [match2]
  end
end
