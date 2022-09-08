class UsersController < ShikimoriController
  respond_to :json, :html, only: :index
  before_action :authenticate_user!, only: :similar

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
      .lazy_map(&:decorate)
  end

  def similar # rubocop:disable all
    og noindex: true
    @threshold = params[:threshold].to_i
    @klass = params[:klass] == Manga.name.downcase ? Manga : Anime

    return redirect_to current_url(threshold: THRESHOLDS[2]) unless THRESHOLDS.include?(@threshold)

    og page_title: i18n_t('similar_users')
    breadcrumb I18n.t('profiles_controller.user_profile'), current_user.url

    @similar_ids = SimilarUsersFetcher.call(
      user: current_user&.object,
      klass: @klass,
      threshold: @threshold
    )

    if @similar_ids
      @collection = Users::Query.new(User.all)
        .where(id: @similar_ids)
        .order_by_ids(@similar_ids)
        .paginate(@page, LIMIT)
        .lazy_map(&:decorate)
    end

    render :index if json?
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
