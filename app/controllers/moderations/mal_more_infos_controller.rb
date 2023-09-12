class Moderations::MalMoreInfosController < ModerationsController
  PER_PAGE = 20

  def index
    og page_title: i18n_t('page_title')

    @animes_collection = fetch Anime
    @mangas_collection = fetch Manga

    @collection = @animes_collection + @mangas_collection
  end

private

  def fetch klass
    scope = klass
      .where("more_info like '%[MAL]'")
      .order(Animes::Filters::OrderBy.arel_sql(scope: klass, term: :ranked))

    QueryObjectBase
      .new(scope)
      .paginate(page, PER_PAGE)
      .lazy_map(&:decorate)
  end
end
