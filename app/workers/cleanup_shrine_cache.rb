class CleanupShrineCache
  include Sidekiq::Worker

  EXPIRE_INTERVAL = 1.day

  def perform expire_interval = EXPIRE_INTERVAL
    storage = Shrine.storages[:cache]
    storage.clear! do |object|
      File.mtime(object) < expire_interval.ago
    end
  end
end
