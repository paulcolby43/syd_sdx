require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SydSdx
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
#    config.active_record.raise_in_transactional_callbacks = true

#    config.action_dispatch.default_headers = {
#      'Access-Control-Allow-Origin' => 'http://50.192.53.46:50003/api/reports/formats',
#      'Access-Control-Request-Method' => %w{GET POST OPTIONS}.join(",")
#    }
    
#    config.middleware.insert_before 0, Rack::Cors do
#      allow do
#         origins '*'
#         resource '*', :headers => :any, :methods => [:get, :post, :options]
#       end
#    end
    
  end
end

require "graphql/client"
require "graphql/client/http"

module DRAGONQLAPI
  # Configure GraphQL endpoint using the basic HTTP network adapter.
#  HTTP = GraphQL::Client::HTTP.new("https://qa-app-scrapdragon-openapi.azurewebsites.net/graphql")
#  HTTP = GraphQL::Client::HTTP.new("https://test-app-scrapdragon-openapi.azurewebsites.net/graphql")
  HTTP = GraphQL::Client::HTTP.new("https://qa-app-scrapdragon-openapi.azurewebsites.net/graphql") do
    def headers(context)
      {
        "Authorization" => "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJhcGk6Ly9hOTMwMWJhYS0zNjQxLTRjMzYtODJhMC1jNDIzYmEyYjFhNzMiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9hMWE1MDc4Mi1kMGIxLTQ3ODItOGM3Yy1hMmQyYzBiN2U3ODQvIiwiaWF0IjoxNjEyODA3NzIwLCJuYmYiOjE2MTI4MDc3MjAsImV4cCI6MTYxMjgxMTYyMCwiYWlvIjoiRTJaZ1lQQnIzcmJSTUhyMmNlRVNuK3VKTEc5bkFRQT0iLCJhcHBpZCI6IjYxYTEyMjgwLWZjOWYtNDIyMy1hYWRmLWM1MDRkOGViYjA0OCIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0L2ExYTUwNzgyLWQwYjEtNDc4Mi04YzdjLWEyZDJjMGI3ZTc4NC8iLCJvaWQiOiIyZThhN2NlOC04YmYzLTQzMmQtYjc1Zi1lZmIwMTk2YWEwMTkiLCJyaCI6IjAuQUFBQWdnZWxvYkhRZ2tlTWZLTFN3TGZuaElBaW9XR2ZfQ05DcXRfRkJOanJzRWhHQUFBLiIsInJvbGVzIjpbIkFwcGxpY2F0aW9uIl0sInN1YiI6IjJlOGE3Y2U4LThiZjMtNDMyZC1iNzVmLWVmYjAxOTZhYTAxOSIsInRpZCI6ImExYTUwNzgyLWQwYjEtNDc4Mi04YzdjLWEyZDJjMGI3ZTc4NCIsInV0aSI6Ijh5RXJTSjFMLTBDZ3B2am0zcGRWQUEiLCJ2ZXIiOiIxLjAifQ.f9wfrzm8cdViUmbJ8yEakoetTFKYYLG2O2O5tC4n8v5U8UuWqQNSQJe38ltasVgRkejtWohJxbxyzDum11x0xCFNtztUv-XXYR_551qishTFqBNC85YlvDQEz3RcnhsZnOXJEGZJedjnqeEBdWHJ-FFefsyX6oZnhe8CMg-D-yECDcHRkTqwGMMvwCFtbvxUNYUAlWHfIQG_gRBx5BFXZrElXxZi7RQtItxNZJ535uyIcocuRAX8a2XAe1udixuZ-ugwgzE4ty8s-JkF6aU-pG5OiUF_MZPEFvpiTGidk9RxBwUCoCVivni9N0iSXI9yurz03-j1VnU5eCkvPzqNlA"
      }
    end
  end 
  
  # Fetch latest schema on init, this will make a network request, However, it's smart to dump this to a JSON file and load from disk.
  # Run it from a script or rake task
  #   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
  #
  # Schema = GraphQL::Client.load_schema("path/to/schema.json")
  Schema = GraphQL::Client.load_schema(HTTP) 
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  
end
