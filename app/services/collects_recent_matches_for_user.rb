class CollectsRecentMatchesForUser
  def initialize
    @retrieve_slack_user_info = Slack::RetrieveSlackUserInfo.new
  end

  def call(user:)
    matches = HistoricalMatch.for_user(user).order(matched_on: :desc)

    matches.map do |match|
      other_members = match.members - [user.slack_user_id]

      RecentMatch.new(
        match_id: match.id,
        slack_user_id: user.slack_user_id,
        grouping: match.grouping,
        matched_on: match.matched_on,
        other_members: other_members.map { |slack_user_id| fetch_user_profile(slack_user_id) },
        match_status: match.status
      )
    end
  end

  private

  def fetch_user_profile(slack_user_id)
    user_profile = SlackUserProfile.find_by(slack_user_id: slack_user_id)

    if user_profile.nil?
      @retrieve_slack_user_info.call(user: slack_user_id)

      user_profile = SlackUserProfile.find_by(slack_user_id: slack_user_id)
    end

    user_profile
  end
end
