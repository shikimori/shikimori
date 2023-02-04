class Achievements::NekoRestart
  include Sidekiq::Worker

  sidekiq_options queue: :high_priority

  def perform
    `sudo systemctl restart neko`
  end
end
