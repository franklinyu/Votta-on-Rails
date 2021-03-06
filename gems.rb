source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1'

gem 'browser', '~> 2.3'

group :doc do
  gem 'yard'
  gem 'yard-restful'
  gem 'redcarpet'
end

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'listen', '~> 3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'factory_girl_rails', '~> 4.7'
  gem 'faker', '~> 1.6'
  gem 'fuubar'
  gem 'simplecov', require: false
end

group :ci, optional: true do
  gem 'codeclimate-test-reporter', '~> 1.0.8'
end

group :production do
  # Use Puma as the app server
  gem 'puma', '~> 3.0'
  gem 'pg'
end
