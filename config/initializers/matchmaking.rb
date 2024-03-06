require_relative "matchmaking/config"

Rails.application.configure do
  config.x.matchmaking = Matchmaking::Config.new(Rails.application.config_for(:matchmaking))
end
