source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0.4"
gem 'rails_admin'
gem 'pg'
gem "sprockets-rails"
gem "puma", "~> 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem 'devise'
gem 'devise-i18n'
gem "jbuilder"
gem 'jquery-rails'
gem "russian"
gem "rails-i18n"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "sqlite3"

group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'launchy'
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem 'sqlite3'
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :production do
end
