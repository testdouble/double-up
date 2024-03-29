ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Disable slack messages from going out in tests
Slack::ClientWrapper.disable!

require "minitest/autorun"
require "mocktail"
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

class ActiveSupport::TestCase
  include ConfigTestHelper
  include DatabaseTestHelper
  include IoTestHelper
  include SlackTestHelper
  include Mocktail::DSL

  parallelize(workers: :number_of_processors)

  fixtures :all

  setup do
    io_refresh!
  end

  teardown do
    Mocktail.reset
    Timecop.return
  end

  def sign_in_as(user)
    get "/auth/verify", params: {token: user.auth_token}
  end
end
