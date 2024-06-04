class RecentMatchesController < ApplicationController
  def index
    load_current_user_profile

    @recent_matches = CollectsRecentMatchesForUser.new.call(user: @current_user)
  end

  private

  def load_current_user_profile
    @user_profile = SlackUserProfile.find_by(slack_user_id: @current_user.slack_user_id)
    return if @user_profile.present?

    Slack::RetrieveSlackUserInfo.new.call(user: @current_user.slack_user_id)

    @user_profile = SlackUserProfile.find_by(slack_user_id: @current_user.slack_user_id)
  end
end
