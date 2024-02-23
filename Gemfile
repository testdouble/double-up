source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.1.2"

gem "rails"
gem "puma"
gem "slack-ruby-client"
gem "pg"
gem "sprockets-rails"
gem "tailwindcss-rails"
gem "importmap-rails"
gem "hotwire-rails"
gem "heroicon"

gem "bugsnag"
gem "sendgrid-actionmailer"

gem "bootsnap", require: false

gem "todo_or_die"

group :development, :test do
  gem "debug"
  gem "dotenv-rails"
  gem "standard"
end

group :development do
  gem "foreman"
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
end

group :test do
  gem "minitest"
  gem "mocktail"
  gem "rspec"
  gem "rspec-rails"
  gem "timecop"
end
