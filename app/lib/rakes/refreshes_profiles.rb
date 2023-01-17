module Rakes
  class RefreshesProfiles
    def initialize
      @retrieves_slack_user_info = Slack::RetrievesSlackUserInfo.new
    end

    def call
      matched_slack_user_ids.map do |slack_user_id|
        slack_user = @retrieves_slack_user_info.call(user: slack_user_id)

        user_profile = SlackUserProfile.find_or_create_by(slack_user_id: slack_user_id)
        user_profile.update(
          name: slack_user.profile.real_name,
          avatar_url: slack_user.profile.image_512
        )

        user_profile
      end
    end

    private

    def matched_slack_user_ids
      HistoricalMatch.all.select(:members).map(&:members).flatten.uniq
    end
  end
end
