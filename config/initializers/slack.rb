Slack.configure do |config|
  config.token = ENV["SLACK_OAUTH_TOKEN"]
end

Slack::Events.configure do |config|
  config.signing_secret = if Rails.env.test?
    "FICTIONAL63fZabecd7c3c89387b6a9X"
  else
    ENV["SLACK_SIGNING_SECRET"]
  end
end
