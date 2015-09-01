class MangasVerifier
  include Sidekiq::Worker
  sidekiq_options unique: true, dead: false, unique_job_expiration: 60 * 60 * 24 * 30
  sidekiq_retry_in { 60 * 60 * 24 }

  BAD_DESCRIPTIONS = [
    "description ilike '%adultmanga%'",
    "description ilike '%doramatv%'",
    "description ilike '%readmanga%'",
    "description ilike '%findanime%'",
    "description ilike '%ru'",
    "description ilike '%com'",
    "description ilike '%org'",
    "description ilike '%info'",
    "description ilike '%http://%'",
    "description ilike '%www.%'",
    "description ilike '%ucoz%'",
    "description ilike '%Удалено по просьбе%'",
    "description ilike '%Редактировать описание'",
    "description ilike '%Описание представлено'"
  ]

  def perform
    MangaMalParser.import bad_entries if bad_entries.any?
    raise "Broken manga descriptions found: #{bad_descriptions.join ', '}" if bad_descriptions.any?
    raise "Broken mangas found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Manga.where(name: nil).pluck :id
  end

  def bad_descriptions
    @bad_descriptions ||= Manga
      .where(BAD_DESCRIPTIONS.join(' or '))
      .where.not(id: [2423, 25252])
      .where.not(id: ChangedItemsQuery.new(Manga).fetch_ids)
      .pluck(:id)
  end
end
