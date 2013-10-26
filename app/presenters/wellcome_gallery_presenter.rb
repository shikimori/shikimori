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
      Anime.where(id: Favourite.where(linked_type: Anime.name).group(:linked_id).order('count(*) desc').limit(50).map(&:linked_id))
            .where(censored: false)
            .includes(:genres)
            .order(:ranked)
            .all,
      Anime.where(AniMangaStatus.query_for('latest'))
            .where(kind: 'TV')
            .where { id.not_in(OngoingsQuery::AnimeIgnored) }
            .where { id.not_in(AniMangaQuery::AnimeSerials) }
            .where { rating.not_eq('None') }
            .where { ranked.not_eq(0) }
            .where(censored: false)
            .includes(:genres)
            .order(:ranked)
            .limit(12)
            .all,
      Anime.where(kind: 'TV')
            .where { id.not_in(OngoingsQuery::AnimeIgnored) }
            .where { id.not_in(AniMangaQuery::AnimeSerials) }
            .where { rating.not_eq('None') }
            .where { ranked.not_eq(0) }
            .where(censored: false)
            .includes(:genres)
            .order(:ranked)
            .limit(84)
            .all,
      Anime.where(kind: 'Movie')
            .where { id.not_in(OngoingsQuery::AnimeIgnored) }
            .where { id.not_in(AniMangaQuery::AnimeSerials) }
            .where { rating.not_eq('None') }
            .where { ranked.not_eq(0) }
            .where(censored: false)
            .includes(:genres)
            .order(:ranked)
            .limit(84)
            .all,
      Anime.where(id: AniMangaQuery::AnimeSerials)
            .where(censored: false)
            .includes(:genres)
            .order(:ranked)
            .all,
      Anime.where(AniMangaStatus.query_for('ongoing'))
            .where(kind: 'TV')
            .where { id.not_in(OngoingsQuery::AnimeIgnored) }
            .where { id.not_in(AniMangaQuery::AnimeSerials) }
            .where { rating.not_eq('None') }
            .where { ranked.not_eq(0) }
            .where(censored: false)
            .includes(:genres)
            .order(:ranked)
            .all
    ].map { |v| v.shuffle.take(6).sort_by { |a| a.ranked } }
  end
end
