Sentry.init do |config|
  config.dsn = ENV.fetch("SENTRY_DSN", "https://5hbu342ztcrPttCdTnPa3ukZ@s2397354.eu-fsn-3.betterstackdata.com/2681859")

  config.enabled_environments = ENV.fetch("SENTRY_ENABLED_ENVIRONMENTS", "production").split(",").map(&:strip)

  config.breadcrumbs_logger = [ :active_support_logger ]

  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.0").to_f
end
