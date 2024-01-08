ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Disable slack messages from going out in tests
Slack::ClientWrapper.disable!

require "minitest/autorun"
require "mocktail"
require_relative "support/config_test_helper"

class ActiveSupport::TestCase
  include ConfigTestHelper
  include Mocktail::DSL

  parallelize(workers: :number_of_processors)

  fixtures :all

  teardown do
    Mocktail.reset
  end
end
