# TODO: specs
class ProgressContests
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    retry: true,
    dead: false,
    queue: :high_priority
  )

  def perform
    Contest.where(state: 'started').each do |contest|
      Contest::Progress.call contest
    end
  end
end
