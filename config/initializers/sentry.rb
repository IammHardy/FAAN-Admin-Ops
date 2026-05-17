Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  config.breadcrumbs_logger = [
    :active_support_logger,
    :http_logger
  ]

  config.send_default_pii = true

  config.environment = Rails.env

  # Only run in production
  config.enabled_environments = %w[production]

  # Capture only some traces (better for production)
  config.traces_sample_rate = 0.2
end