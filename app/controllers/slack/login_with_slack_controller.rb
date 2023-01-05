module Slack
  class LoginWithSlackController < SlashCommandController
    def handle
      # {
      #   "token"=>"[FILTERED]",
      #   "team_id"=>"T02HPRG01AN",
      #   "team_domain"=>"testdoubleplay",
      #   "channel_id"=>"D02H95797RV",
      #   "channel_name"=>"directmessage",
      #   "user_id"=>"U02J2DURMU1",
      #   "user_name"=>"kenneth.bogner",
      #   "command"=>"/doubleup",
      #   "text"=>"",
      #   "api_app_id"=>"A02JHJF43N3",
      #   "is_enterprise_install"=>"false",
      #   "response_url"=>"https://hooks.slack.com/commands/T02HPRG01AN/4555190839444/d0PqVGpXyiQ41yhbgQfar125",
      #   "trigger_id"=>"4576431983232.2601866001362.7e817ff88a1bf3f9f68b688761504d7b"
      # }
      puts params
      render plain: "pong"
    end
  end
end
