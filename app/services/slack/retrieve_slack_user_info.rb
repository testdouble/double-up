module Slack
  class RetrieveSlackUserInfo
    include RateLimitRetryable

    def call(user:)
      response = retry_when_rate_limited do
        ClientWrapper.client.users_info(user: user)
      end

      cache_user_info(response&.user, user)

      response&.user
    end

    private

    def cache_user_info(user, slack_user_id)
      return unless user.present?

      user_profile = SlackUserProfile.find_or_create_by(slack_user_id: slack_user_id)
      user_profile.update(
        name: user.profile.real_name,
        avatar_url: user.profile.image_512
      )
    end
  end
end
