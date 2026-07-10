Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  config.breadcrumbs_logger = [
    :active_support_logger,
    :http_logger
  ]

  # This app stores staff PII (real names, phone numbers) and incident details.
  # Do not forward personally identifiable information to Sentry by default. Set
  # SENTRY_SEND_PII=true only if your data-governance policy explicitly allows it.
  config.send_default_pii = ENV["SENTRY_SEND_PII"] == "true"
  config.environment = Rails.env
  config.enabled_environments = %w[production]
  config.traces_sample_rate = 0.2
end