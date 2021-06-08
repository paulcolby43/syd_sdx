require 'microsoft_auth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :microsoft_auth,
           ENV['AZURE_APP_ID'],
           ENV['AZURE_APP_SECRET'],
           :scope => ENV['AZURE_SCOPES']
end