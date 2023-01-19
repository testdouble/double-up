module Auth
  class LoginController < ApplicationController
    skip_before_action :require_login

    def verify
      result = Auth::ValidatesLoginAttempt.new.call(params[:token])
      if result.success?
        reset_session
        session[:user_id] = result.user.id
        redirect_to recent_matches_path
      else
        render plain: "Unable to verify", status: :unauthorized
      end
    end

    def log_out
      reset_session
      redirect_to recent_matches_path
    end
  end
end
