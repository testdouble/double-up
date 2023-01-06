Rails.application.routes.draw do
  if Rails.env.test?
    TestOnlyRoutes = ActionDispatch::Routing::RouteSet.new unless defined?(::TestOnlyRoutes)
    mount TestOnlyRoutes, at: "/"
  end

  constraints Constraints::MatchesCommand.new(command: "login") do
    post "/command/handle", to: "slack/login_with_slack_command#handle"
  end
end
