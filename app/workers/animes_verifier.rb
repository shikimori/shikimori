class AnimesVerifier
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    dead: false,
    unique_job_expiration: 60 * 60 * 24 * 30
  )
  sidekiq_retry_in { 60 * 60 * 24 }

  def perform
    AnimeMalParser.import bad_entries if bad_entries.any?
    raise "Broken animes found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Anime.where(name: nil).pluck :id
  end
end
