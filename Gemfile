source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.0"

gem "rails", "~> 6.1.4"
gem "puma", "~> 5.6"
gem "slack-ruby-client"
gem "bootsnap", ">= 1.4.4", require: false
gem "pg", "~> 1.2"
gem "bugsnag", "~> 6.24"
gem "sendgrid-actionmailer"
gem "todo_or_die"

group :development, :test do
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "standard"
end

group :development do
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
end

group :test do
  gem "rspec"
  gem "rspec-rails"
end
