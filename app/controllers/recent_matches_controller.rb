class RecentMatchesController < ApplicationController
  def show
    load_current_user_profile

    @user_matches = ViewHelpers::CollectsMatchesForUser.new.call(user: @current_user)
  end

  private

  def load_current_user_profile
    @user_profile = SlackUserProfile.find_by(slack_user_id: @current_user.slack_user_id)
    return if @user_profile.present?

    Slack::RetrievesSlackUserInfo.new.call(user: @current_user.slack_user_id)

    @user_profile = SlackUserProfile.find_by(slack_user_id: @current_user.slack_user_id)
  end
end
