class ApplicationController < ActionController::Base
  before_action :require_login

  def require_login
    @current_user = User.find_by(id: session[:user_id])
    return if @current_user.present?

    render plain: "Run /doubleup login in Slack to authenticate", status: :unauthorized
  end
end
