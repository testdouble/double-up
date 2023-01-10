module Auth
  class VerifyLoginController < ApplicationController
    skip_before_action :require_login

    def verify
      result = Auth::ValidatesLoginAttempt.new.call(params[:token])
      if result.success?
        reset_session
        session[:user_id] = result.user.id
        redirect_to history_path
      else
        render plain: "Unable to verify", status: :unauthorized
      end
    end
  end
end
