class Moderations::PostersController < ModerationsController
  load_and_authorize_resource
  before_action :check_access

  PER_PAGE = 20

  def index # rubocop:disable Metrics/AbcSize
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    @default_state = Types::Moderatable::State[:pending].to_s
    @state = params[:state].presence || @default_state
    @states = Poster.aasm(:moderation_state).states.map { |v| v.name.to_s }

    @counts = @states.index_with { |state| scope(state).count } unless json?

    @collection = QueryObjectBase
      .new(scope(@state))
      .includes(:manga)
      .paginate(page, PER_PAGE)
  end

  def accept
    @resource.accept! approver: current_user
    redirect_back fallback_location: moderations_posters_url
  end

  def reject
    @resource.reject! approver: current_user
    redirect_back fallback_location: moderations_posters_url
  end

  def cancel
    @resource.cancel!
    redirect_back fallback_location: moderations_posters_url
  end

private

  def scope moderation_state
    Animes::CensoredPostersQuery.call(
      klass: Manga,
      moderation_state:
    )
  end

  def check_access
    authorize! :moderate_censored, Poster
  end
end
