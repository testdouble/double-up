class ProfileController < ApplicationController
  def show
    load_current_user_profile(params[:slack_user_id])

    @user = User.find_by(slack_user_id: params[:slack_user_id])
  end

  private

  def load_current_user_profile(slack_user_id)
    @user_profile = SlackUserProfile.find_by(slack_user_id: slack_user_id)
    return if @user_profile.present?

    Slack::RetrieveSlackUserInfo.new.call(user: slack_user_id)

    @user_profile = SlackUserProfile.find_by(slack_user_id: slack_user_id)
  end
end
