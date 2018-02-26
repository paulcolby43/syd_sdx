if Rails.env == "production" || Rails.env == "staging" || Rails.env == "development"

  exceptions = []
  exceptions << 'ActiveRecord::RecordNotFound'
  exceptions << 'AbstractController::ActionNotFound'
  exceptions << 'ActionController::RoutingError'
  exceptions << 'ActionController::InvalidAuthenticityToken'

  Rails.application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :sender_address => %{"Dragon Dog Exception Notifier" <notifier@tranact.com>},
    :exception_recipients => %w{jeremy@tranact.com shark@tranact.com}
  },
  ignore_exceptions: exceptions

end