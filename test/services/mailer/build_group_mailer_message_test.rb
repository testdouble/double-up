require "test_helper"

module Mailer
  class BuildGroupMailerMessageTest < ActiveSupport::TestCase
    setup do
      @retrieves_slack_user_info = Mocktail.of_next(Slack::RetrievesSlackUserInfo)
      @subject = BuildGroupMailerMessage.new
    end

    test "builds a mailer message for a group" do
      recipient = Mailer::MatchMember.new(
        email: "holmes@deduction.com",
        name: "Sherlock"
      )
      other_member = Mailer::MatchMember.new(
        email: "watson@deduction.com",
        name: "John Watson"
      )

      mailer = @subject.render(
        recipient: recipient,
        grouping: "test_time",
        channel: "rotating-test",
        other_members: [other_member]
      )

      assert_equal ["holmes@deduction.com"], mailer.to
      assert_equal ["doubot@testdouble.com"], mailer.from
      assert_equal ["watson@deduction.com"], mailer.reply_to
      assert_equal "Test Time with John Watson", mailer.subject
      assert_match(/Howdy Sherlock/, mailer.body.to_s)
      assert_match(/You've been matched up with John Watson for Test Time from the #rotating-test Slack channel/, mailer.body.to_s)
    end
  end
end
