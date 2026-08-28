redis = Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379")

Stoplight.configure do |config|
  config.data_store = Stoplight::DataStore::Redis.new(redis)
  config.notifiers += [Stoplight::Notifier::Logger.new(Rails.logger)]
end
