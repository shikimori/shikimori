class VerifyMangasJob
  def perform
    MangaMalParser.import bad_entries if bad_entries.any?
    raise "Broken manga descriptions found: #{bad_descriptions.join ', '}" if bad_descriptions.any?
    raise "Broken mangas found: #{bad_entries.join ', '}" if bad_entries.any?
  end

  def bad_entries
    Manga.where(name: nil).pluck :id
  end

  def bad_descriptions
    @bad_descriptions ||= Manga.where {
        description.like('%adultmanga%') |
        description.like('%doramatv%') |
        description.like('%readmanga%') |
        description.like('%findanime%') |
        description.like('%ru') |
        description.like('%com') |
        description.like('%org') |
        description.like('%info') |
        description.like('%http://%') |
        description.like('%www.%') |
        description.like('%ucoz%') |
        description.like('%Удалено по просьбе%') |
        description.like('%Редактировать описание') |
        description.like('%Описание представлено')
      }
      .where { id.not_in [2423] }
      .pluck(:id)
  end
end
