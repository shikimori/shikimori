class Moderations::PostersController < ModerationsController
  PER_PAGE = 20

  def index # rubocop:disable Metrics/AbcSize
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    @states = Poster.aasm(:moderation_state).states.map(&:name).map(&:to_s)
    @default_state = Types::Moderatable::State[:pending]
    @state = params[:state].presence || @default_state

    @counts = @states.index_with { |state| scope(state).count }

    @collection = QueryObjectBase
      .new(scope(@state))
      .includes(:manga)
      .paginate(page, PER_PAGE)
  end

private

  def scope moderation_state
    Animes::CensoredPostersQuery.call(
      klass: Manga,
      moderation_state:
    )
  end
end
