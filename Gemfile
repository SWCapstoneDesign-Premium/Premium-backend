source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.3.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'figaro'

# serializer 
gem 'panko_serializer'
#gem 'active_model_serializers'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
gem "actionpack-page_caching"
gem "actionpack-action_caching"
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'
gem 'sassc-rails'
gem 'devise'
gem 'activeadmin'
gem 'arctic_admin'

gem 'devise-i18n'

gem 'jwt_sessions'
# # gem 'pry', '~> 0.13.1'
gem 'pry-rails'
gem 'pry'
gem 'redis'
gem 'omniauth'
gem 'omniauth-kakao', git: "https://github.com/DevStarSJ/omniauth-kakao"

gem 'ransack'
gem 'fog-aws'
gem 'listen', '~> 3.2'
gem 'chromedriver-helper'
gem 'selenium-webdriver'

gem 'capistrano', '3.14.1'
gem 'capistrano-rails'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-webpacker-precompile', require: false
gem 'capistrano-bundler'
gem 'capistrano-rbenv'
gem 'capistrano-rails-collection'
gem 'capistrano-figaro-yml'
gem 'capistrano-database-yml'
gem 'rubocop', require: false
gem 'faker'
gem "paranoia"
gem 'omniauth-apple'
gem 'bootstrap', '~> 4.3.1'
gem 'httparty'
# gem 'iamport'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'rails_db'
  
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'carrierwave'
gem 'mini_magick'

gem 'activerecord-import'

gem 'sendgrid-actionmailer'