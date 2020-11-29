class UsersController < ShikimoriController
  respond_to :json, :html, only: :index

  LIMIT = 15
  THRESHOLDS = [100, 175, 350]

  def index
    og page_title: i18n_i('User', :other)

    scope = Users::Query.fetch

    if params[:search].present?
      scope = scope.search(params[:search])
    end

    @collection = scope
      .paginate(@page, LIMIT)
      .transform(&:decorate)
  end

  def similar # rubocop:disable all
    og noindex: true
    @threshold = params[:threshold].to_i
    @klass = params[:klass] == Manga.name.downcase ? Manga : Anime

    return redirect_to current_url(threshold: THRESHOLDS[2]) unless THRESHOLDS.include?(@threshold)

    og page_title: i18n_t('similar_users')
    breadcrumb i18n_i('User', :other), users_url

    @similar_ids = SimilarUsersFetcher.call(
      user: current_user&.object,
      klass: @klass,
      threshold: @threshold
    )

    if @similar_ids
      ids = @similar_ids
        .drop(LIMIT * (@page - 1))
        .take(LIMIT)

      @collection = User
        .where(id: ids)
        .sort_by { |user| ids.index user.id }
        .map(&:decorate)
    end

    @add_postloader = @similar_ids&.any? &&
      @page * LIMIT < SimilarUsersService::MAXIMUM_RESULTS
  end

  def autocomplete
    @collection = Users::Query.fetch
      .search(params[:search])
      .paginate(1, CompleteQuery::AUTOCOMPLETE_LIMIT)
  end

private

  def cache_key
    [:search, params[:search], @page, CACHE_VERSION]
  end
end
