Rails.application.routes.draw do
  if Rails.env.test?
    TestOnlyRoutes = ActionDispatch::Routing::RouteSet.new unless defined?(::TestOnlyRoutes)
    mount TestOnlyRoutes, at: "/"
  end

  post "/command/handle", to: "slack/login_with_slack#handle", constraints: Constraints::MatchesCommand.new(command: "login")
end
