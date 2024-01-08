ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |file| require file }

# Disable slack messages from going out in tests
Slack::ClientWrapper.disable!

require "minitest/autorun"
