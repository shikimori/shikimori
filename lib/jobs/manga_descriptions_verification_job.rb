class MangaDescriptionsVerificationJob
  def perform
    bad_mangas = Manga.where {
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
      .select(:id)
      .map(&:id)
      .map(&:to_s)
    raise "Broken manga descriptions found: #{bad_mangas.join(' ')}" if bad_mangas.any?
  end
end
