class CleanupShrineCache < ApplicationJob
  EXPIRE_INTERVAL = 1.day

  def perform
    storage = Shrine.storages[:cache]
    storage.clear! do |object|
      File.mtime(object) < EXPIRE_INTERVAL.ago
    end
  end
end
