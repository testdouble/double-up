require "test_helper"

module Slack
  class RetrieveSlackUserInfoTest < ActiveSupport::TestCase
    setup do
      @subject = RetrieveSlackUserInfo.new
    end

    test "loads a user's information from slack" do
      stub_slack_client do |slack_client|
        @subject.call(user: "USER_ID")

        verify { slack_client.users_info(user: "USER_ID") }
      end
    end

    test "stores some user profile information to the database" do
      stub_slack_client do |slack_client|
        stubs { slack_client.users_info(user: "USER_ID") }.with do
          slack_user_response("USER_ID")
        end

        assert_difference -> { SlackUserProfile.count } do
          @subject.call(user: "USER_ID")
        end

        user_profile = SlackUserProfile.find_by(slack_user_id: "USER_ID")
        assert_equal "Luke", user_profile.name
      end
    end

    private

    def slack_user_response(id)
      Slack::Messages::Message.new(
        id: id,
        user: Slack::Messages::Message.new(
          id: id,
          profile: Slack::Messages::Message.new(
            real_name: "Luke",
            image_512: "https://example.com/x/512/512"
          )
        )
      )
    end
  end
end
