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
        description like '%adultmanga%' or
        description like '%doramatv%' or
        description like '%readmanga%' or
        description like '%findanime%' or
        description like '%ru' or
        description like '%com' or
        description like '%org' or
        description like '%info' or
        description like '%http://%' or
        description like '%www.%' or
        description like '%ucoz%' or
        description like '%Удалено по просьбе%' or
        description like '%Редактировать описание' or
        description like '%Описание представлено'
      ")
      .where.not(id: [2423])
      .pluck(:id)
  end
end
