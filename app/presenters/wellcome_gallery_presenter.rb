# для галереи на главной странице
class WellcomeGalleryPresenter < LazyPresenter
  lazy_loaded :data, :index

  # сколько всего разных вариантов галереи кешировать
  Variants = 15

  # ключ от кеша
  def cache_key
    @key ||= "#{self.class.name}___#{(rand * 100).to_i % Variants}_#{(AnimeNews.last || { id: 'nil' })[:id]}"
  end

  # загрузка данных
  def lazy_load
    @index = ['favourites', 'latest', 'tv',' movies', 'serials', 'ongoing']
    @data = [
      Anime
        .where(id: FavouritesQuery.new.top_favourite_ids(Anime, 50))
        .where(censored: false)
        .includes(:genres)
        .order(:ranked)
        .to_a,
      Anime
        .where(AniMangaStatus.query_for('latest'))
        .where(kind: 'TV')
        .where.not(id: Anime::EXCLUDED_ONGOINGS)
        .where.not(id: AniMangaQuery::AnimeSerials)
        .where.not(rating: 'None')
        .where.not(ranked: 0)
        .where(censored: false)
        .includes(:genres)
        .order(:ranked)
        .limit(12)
        .to_a,
      Anime
        .where(kind: 'TV')
        .where.not(id: Anime::EXCLUDED_ONGOINGS)
        .where.not(id: AniMangaQuery::AnimeSerials)
        .where.not(rating: 'None')
        .where.not(ranked: 0)
        .where(censored: false)
        .includes(:genres)
        .order(:ranked)
        .limit(84)
        .to_a,
      Anime
        .where(kind: 'Movie')
        .where.not(id: Anime::EXCLUDED_ONGOINGS)
        .where.not(id: AniMangaQuery::AnimeSerials)
        .where.not(rating: 'None')
        .where.not(ranked: 0)
        .where(censored: false)
        .includes(:genres)
        .order(:ranked)
        .limit(84)
        .to_a,
      Anime
        .where(id: AniMangaQuery::AnimeSerials)
        .where(censored: false)
        .includes(:genres)
        .order(:ranked)
        .to_a,
      Anime
        .where(AniMangaStatus.query_for('ongoing'))
        .where(kind: 'TV')
        .where.not(id: Anime::EXCLUDED_ONGOINGS)
        .where.not(id: AniMangaQuery::AnimeSerials)
        .where.not(rating: 'None')
        .where.not(ranked: 0)
        .where(censored: false)
        .includes(:genres)
        .order(:ranked)
        .to_a
    ].map { |v| v.shuffle.take(6).sort_by { |a| a.ranked } }
  end
end
