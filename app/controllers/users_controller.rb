class UsersController < ShikimoriController
  respond_to :json, :html, only: :index

  LIMIT = 15
  THRESHOLDS = [25, 50, 100, 175, 350]

  # список всех пользователей
  def index
    @page = [params[:page].to_i, 1].max
    @limit = LIMIT

    page_title i18n_i('User', :other)

    @collection = Users::Query.fetch
      .search(params[:search])
      .paginate(@page, @limit)
      .transform(&:decorate)
  end

  # rubocop:disable MethodLength
  # rubocop:disable AbcSize
  def similar
    noindex
    @page = [params[:page].to_i, 1].max
    @limit = LIMIT
    @threshold = params[:threshold].to_i
    @klass = params[:klass] == Manga.name.downcase ? Manga : Anime

    unless THRESHOLDS.include?(@threshold)
      redirect_to similar_users_path(url_params(threshold: THRESHOLDS[2]))
      return
    end

    page_title i18n_t('similar_users')
    breadcrumb i18n_i('User', :other), users_url

    @similar_ids = SimilarUsersFetcher
      .new(current_user&.object, @klass, @threshold)
      .fetch

    if @similar_ids
      ids = @similar_ids
        .drop(@limit * (@page - 1))
        .take(@limit)

      @collection = User
        .where(id: ids)
        .sort_by { |user| ids.index user.id }
        .map(&:decorate)
    end

    @add_postloader =
      @similar_ids && @similar_ids.any? &&
        @page * @limit < SimilarUsersService::MAXIMUM_RESULTS
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength

  # автодополнение
  def autocomplete
    @collection = Users::Query.fetch
      .search(params[:search])
      .paginate(1, CompleteQuery::AUTOCOMPLETE_LIMIT)
      .reverse
  end
end
