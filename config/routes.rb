Rails.application.routes.draw do
  if Rails.env.test?
    TestOnlyRoutes = ActionDispatch::Routing::RouteSet.new unless defined?(::TestOnlyRoutes)
    mount TestOnlyRoutes, at: "/"
  end

  constraints Constraints::MatchesCommand.new(command: "login") do
    post "/command/handle", to: "slack/login_with_slack_command#handle", as: "login_command"
  end

  post "/command/handle", to: "slack/slash_command#handle"

  match "/auth/verify", to: "auth/login#verify", via: [:get, :post], as: "verify_login"
  match "/auth/logout", to: "auth/login#log_out", via: [:get, :post, :delete], as: "log_out"

  # Authenticated routes
  root to: "root#index"

  get "/matches", to: "recent_matches#index", as: "recent_matches"
  get "/profile/:slack_user_id", to: "profile#show", as: "profile"
  resources :calendar_links, except: [:show]

  resources :matchmaking_groups, only: [:index, :new, :create, :edit, :update, :destroy]
end
