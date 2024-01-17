module Auth
  class GeneratesToken
    TOKEN_LIFETIME = 30

    def call(user)
      unless user.auth_token.present? && user.auth_token_expires_at.future?
        user.update!(
          auth_token: SecureRandom.urlsafe_base64,
          auth_token_expires_at: TOKEN_LIFETIME.minutes.from_now
        )
      end

      user.auth_token
    end
  end
end
