class SidekiqHeartbeat < ActiveJob::Base
  prepend ActiveCacher.instance

  instance_cache :enqueued, :busy, :queues

  MAX_ENQUEUED_TASKS = 5

  def perform
    return unless Rails.env.production?
    cache_sidekiq_stats
    return unless enqueued > MAX_ENQUEUED_TASKS && busy.zero?

    restart_sidekiq
    log
  end

private

  def cache_sidekiq_stats
    enqueued
    busy
    queues
  end

  def enqueued
    Sidekiq::Stats.new.enqueued
  end

  def busy
    Sidekiq::ProcessSet.new.sum { |process| process['busy'] }
  end

  def queues
    Sidekiq::Stats.new.queues
  end

  def restart_sidekiq
    `sudo /etc/init.d/shikimori_sidekiq_#{Rails.env} stop`
    `sudo /etc/init.d/shikimori_sidekiq_#{Rails.env} start`
  end

  def log
    data = {
      enqueued: enqueued,
      body: busy,
      queues: queues
    }
    NamedLogger.sidekiq_heartbeat.info data.to_json
  end
end
