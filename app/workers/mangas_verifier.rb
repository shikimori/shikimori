class MangasVerifier
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: false

  def perform
    MangaMalParser.import bad_entries if bad_entries.any?
    raise "Broken manga descriptions found: #{bad_descriptions.join ', '}" if bad_descriptions.any?
    raise "Broken mangas found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Manga.where(name: nil).pluck :id
  end

  def bad_descriptions
    @bad_descriptions ||= Manga.where("
        description ilike '%adultmanga%' or
        description ilike '%doramatv%' or
        description ilike '%readmanga%' or
        description ilike '%findanime%' or
        description ilike '%ru' or
        description ilike '%com' or
        description ilike '%org' or
        description ilike '%info' or
        description ilike '%http://%' or
        description ilike '%www.%' or
        description ilike '%ucoz%' or
        description ilike '%Удалено по просьбе%' or
        description ilike '%Редактировать описание' or
        description ilike '%Описание представлено'
      ")
      .where.not(id: [2423])
      .pluck(:id)
  end
end
