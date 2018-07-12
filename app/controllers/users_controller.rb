class UsersController < ShikimoriController
  respond_to :json, :html, only: :index

  LIMIT = 15
  THRESHOLDS = [100, 175, 350]

  def index
    @page = [params[:page].to_i, 1].max
    @limit = LIMIT

    og page_title: i18n_i('User', :other)

    @collection = Users::Query.fetch
      .search(params[:search])
      .paginate(@page, @limit)
      .transform(&:decorate)
  end

  def similar # rubocop:disable MethodLength, AbcSize
    og noindex: true
    @page = [params[:page].to_i, 1].max
    @limit = LIMIT
    @threshold = params[:threshold].to_i
    @klass = params[:klass] == Manga.name.downcase ? Manga : Anime

    unless THRESHOLDS.include?(@threshold)
      return redirect_to current_url(threshold: THRESHOLDS[2])
    end

    og page_title: i18n_t('similar_users')
    breadcrumb i18n_i('User', :other), users_url

    @similar_ids = SimilarUsersFetcher.call(
      user: current_user&.object,
      klass: @klass,
      threshold: @threshold
    )

    if @similar_ids
      ids = @similar_ids
        .drop(@limit * (@page - 1))
        .take(@limit)

      @collection = User
        .where(id: ids)
        .sort_by { |user| ids.index user.id }
        .map(&:decorate)
    end

    @add_postloader = @similar_ids&.any? &&
      @page * @limit < SimilarUsersService::MAXIMUM_RESULTS
  end

  def autocomplete
    @collection = Users::Query.fetch
      .search(params[:search])
      .paginate(1, CompleteQuery::AUTOCOMPLETE_LIMIT)
      .reverse
  end
end
