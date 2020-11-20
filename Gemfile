source 'https://rubygems.org'

#ruby '2.2.3'
## Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '4.2.5.1'
##ruby-gemset=rails425

ruby '2.1.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'
#ruby-gemset=rails418

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
 gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# jQuery plugin for drop-in fix binded events problem caused by Turbolinks
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use haml
gem 'haml'

# REST api calls
gem 'rest-client', require: 'rest-client'

# Twitter Bootstrap styling
gem 'twbs_sass_rails'

gem 'haml-rails'

# Encrypt passwords
gem "bcrypt", :require => "bcrypt"

# Pagination
gem 'kaminari-bootstrap'

# Background jobs
#gem 'sidekiq'
# Paid 'Pro' version
source "https://gems.contribsys.com/" do
  gem 'sidekiq-pro'
end

# Image processing
gem 'rmagick', :require => false

# File uploads for Rails, Sinatra and other Ruby web frameworks - https://github.com/carrierwaveuploader/carrierwave
gem 'carrierwave'

# Set environment variables within application.yml
gem "figaro"

# Connect to MS SQL Database
gem 'tiny_tds' 
gem 'activerecord-sqlserver-adapter'

# Needed for sidekiq  web interface 
gem 'sinatra', :require => nil

# Multi-parameter searching
gem "polyamorous"#, :github => "activerecord-hackery/polyamorous"
gem "ransack"#, github: "activerecord-hackery/ransack", branch: "rails-4.1"

# Provide a clear syntax for writing and deploying cron jobs.
gem 'whenever', :require => false

# Authorization
gem 'cancancan'

# Administration interface
gem 'activeadmin', github: 'gregbell/active_admin'
# Flexible authentication solution for Rails with Warden. http://blog.plataformatec.com.br/tag/devise/
gem 'devise'

# PDF generator (from HTML) plugin
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# A Datepicker for Twitter Bootstrap, integrated with Rails assets pipeline
gem 'bootstrap-datepicker-rails'

# SOAP calls (TUD devices web service calls)
gem 'savon'

# Integrate Select2 javascript library with Rails asset pipeline https://github.com/argerim/select2-rails
gem "select2-rails"

# Exception notifications
gem 'exception_notification'

# Dynamically add and remove nested has_many association fields in a Ruby on Rails form
gem 'nested_form_fields'

# morris.js Graphs for the Rails Asset Pipeline
gem 'morrisjs-rails'
gem 'raphael-rails'

# Ruby EXIF reader
gem 'exif'

# Allow Rails request.remote_ip to defer to CloudFlare's connecting IP
gem 'actionpack-cloudflare'

gem "font-awesome-rails"

gem 'simple_form'

#gem 'zip_tricks'
#gem 'zipline'
#gem 'rubyzip'

# Better downloading
#gem 'down'


# https://github.com/cyu/rack-cors
#gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#  gem 'spring'
  
  # Adds logging of the RestClient requests to the Rails debug log
  gem 'rest-client-logger', '~> 0.0.1'
end

