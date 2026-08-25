Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  config.enabled_environments = ENV.fetch("SENTRY_ENABLED_ENVIRONMENTS", "production").split(",").map(&:strip)

  config.breadcrumbs_logger = [ :active_support_logger ]

  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.0").to_f
end
