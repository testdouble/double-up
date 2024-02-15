require "test_helper"

module Notify
  class UseEmailToDeliverNotificationTest < ActiveSupport::TestCase
    setup do
      # Mocktail wasn't working for a class like GroupingMailer. It was returning nil
      # and it wasn't clear why. I decided to use Minitest::Mock instead.
      @mailer = Minitest::Mock.new
      @retrieves_slack_user_info = Mocktail.of_next(Slack::RetrievesSlackUserInfo)
      @build_group_mailer_message = Mocktail.of_next(Mailer::BuildGroupMailerMessage)

      @group = group_with(name: "test", slack_channel_name: "test-channel")

      @subject = UseEmailToDeliverNotification.new
    end

    test "sends an email to all members" do
      notification = create_pending_email_notification
      create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [notification]
      )

      stubs { @retrieves_slack_user_info.call(user: "USER_ID_1") }.with {
        slack_user_message("USER_ID_1", "Luke", "luke@rebels.com")
      }
      stubs { @retrieves_slack_user_info.call(user: "USER_ID_2") }.with {
        slack_user_message("USER_ID_2", "Leia", "leia@rebels.com")
      }
      stubs { |m|
        @build_group_mailer_message.render(
          recipient: Mailer::MatchMember.new(name: "Luke", email: "luke@rebels.com"),
          channel: "test-channel",
          grouping: "test",
          other_members: [
            Mailer::MatchMember.new(name: "Leia", email: "leia@rebels.com")
          ]
        )
      }.with { @mailer }
      stubs {
        @build_group_mailer_message.render(
          recipient: Mailer::MatchMember.new(name: "Leia", email: "leia@rebels.com"),
          channel: "test-channel",
          grouping: "test",
          other_members: [
            Mailer::MatchMember.new(name: "Luke", email: "luke@rebels.com")
          ]
        )
      }.with { @mailer }
      2.times { @mailer.expect :deliver_now, nil }

      @subject.call(notification, @group)

      @mailer.verify
    end

    test "does not send an email if the strategy is not email" do
      notification = create_pending_slack_notification
      create_historical_match(
        grouping: "test",
        members: ["USER_ID_1", "USER_ID_2"],
        pending_notifications: [notification]
      )

      stubs { |m| @retrieves_slack_user_info.call(user: m.any) }
        .with { raise "Should not be called" }
      stubs { |m|
        @build_group_mailer_message.render(
          recipient: m.any,
          channel: m.any,
          grouping: m.any,
          other_members: m.any
        )
      }.with { raise "Should not be called" }

      @subject.call(notification, @group)

      @mailer.verify
    end

    private

    def slack_user_message(id, real_name, email)
      Slack::Messages::Message.new(
        id: id,
        profile: Slack::Messages::Message.new(real_name: real_name, email: email)
      )
    end
  end
end
