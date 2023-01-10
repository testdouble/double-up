module Auth
  class FindsOrCreatesUser
    def call(slack_user_id)
      user = User.find_or_create_by(slack_user_id: slack_user_id)

      if user.persisted?
        user
      end
    end
  end
end
