Rails.application.routes.draw do
  if Rails.env.test?
    TestOnlyRoutes = ActionDispatch::Routing::RouteSet.new unless defined?(::TestOnlyRoutes)
    mount TestOnlyRoutes, at: "/"
  end

  constraints Constraints::MatchesCommand.new(command: "login") do
    post "/command/handle", to: "slack/login_with_slack_command#handle"
  end

  post "/command/handle", to: "slack/slash_command#handle"

  match "/auth/verify", to: "auth/verify_login#verify", via: [:get, :post], as: "verify_login"

  # Authenticated routes
  get "/history", to: "history#show", as: "history"
end
