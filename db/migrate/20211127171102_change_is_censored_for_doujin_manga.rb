class ChangeIsCensoredForDoujinManga < ActiveRecord::Migration[5.2]
  def up
    manga_scope.each do |manga|
      puts "migraging manga ID=#{manga.id}"
      manga.update! is_censored: manga.genres.any?(&:censored?)
    end
  end

  def down
    manga_scope.update_all is_censored: true, updated_at: Time.zone.now
  end

private

  def manga_scope
    Animes::Query.fetch(
      scope: Manga.all,
      params: { genre: Genre::DOUJINSHI_IDS.join(',') },
      user: nil,
      is_apply_excludes: false
    )
  end
end
