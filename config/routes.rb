Rails.application.routes.draw do
  if Rails.env.test?
    TestOnlyRoutes = ActionDispatch::Routing::RouteSet.new unless defined?(::TestOnlyRoutes)
    mount TestOnlyRoutes, at: "/"
  end

  post "/command/doubleup", to: "chatops/slack_slash_command#handle"
end
