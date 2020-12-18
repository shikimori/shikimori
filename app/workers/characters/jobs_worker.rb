class Characters::JobsWorker
  include Sidekiq::Worker

  def perform
    Character.transaction do
      scope.update_all is_anime: false, is_manga: false, is_ranobe: false

      scope.where(id: anime_ids).update_all is_anime: true
      scope.where(id: manga_ids).update_all is_manga: true
      scope.where(id: ranobe_ids).update_all is_ranobe: true
    end
  end

private

  def scope
    Character.all
  end

  def anime_ids
    PersonRole
      .where.not(character_id: nil)
      .where.not(anime_id: nil)
      .pluck(:character_id)
      .uniq
  end

  def manga_ids
    PersonRole
      .where.not(character_id: nil)
      .where.not(manga_id: nil)
      .joins(
        <<~SQL.squish
          inner join mangas on mangas.id = manga_id and
            mangas.kind != 'novel' and mangas.kind != 'light_novel'
        SQL
      )
      .pluck(:character_id)
      .uniq
  end

  def ranobe_ids
    PersonRole
      .where.not(character_id: nil)
      .where.not(manga_id: nil)
      .joins(
        <<~SQL.squish
          inner join mangas on mangas.id = manga_id and
            (mangas.kind = 'novel' or mangas.kind = 'light_novel')
        SQL
      )
      .pluck(:character_id)
      .uniq
  end
end
