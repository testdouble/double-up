module Mailer
  class MatchMember < Struct.new(:name, :email, keyword_init: true)
    def self.from_slack_user(slack_user)
      new(name: slack_user.profile.real_name, email: slack_user.profile.email)
    end
  end
end
