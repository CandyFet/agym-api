# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'active_model_serializers'
gem 'bcrypt'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'factory_bot_rails'
gem 'faker', '2.1.2'
gem 'kaminari'
gem 'octokit', '~> 4.0'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
gem 'rspec-rails'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'sqlite3', '1.4.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'pg', '1.1.4'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
