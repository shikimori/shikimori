class Moderations::PostersController < ModerationsController
  load_and_authorize_resource

  PER_PAGE = 20

  Kind = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:anime, :manga)

  Klass = Types::Strict::Class
    .constructor { |v| v.to_s.classify.constantize }
    .enum(Anime, Manga)

  helper_method :scope

  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    authorize! :censore, Poster

    og page_title: i18n_t('page_title')

    @default_state = Types::Moderatable::State[:pending].to_s
    @state = params[:state].presence || @default_state
    @states = Poster.aasm(:moderation_state).states.map { |v| v.name.to_s }
    @klass = Klass[Kind[params[:kind]]]

    unless json?
      @counts = @states.index_with do |state|
        scope(klass: @klass, moderation_state: state).count
      end
    end

    @collection = QueryObjectBase
      .new(scope(klass: @klass, moderation_state: @state))
      .includes(:manga, :approver)

    poster_by_id if params[:id]

    @collection = @collection.paginate(page, PER_PAGE)
  end

  def accept
    @resource.accept! approver: current_user
    render partial: 'moderations/posters/poster', object: @resource
  end

  def reject
    @resource.reject! approver: current_user
    render partial: 'moderations/posters/poster', object: @resource
  end

  def censore
    @resource.censore! approver: current_user
    render partial: 'moderations/posters/poster', object: @resource
  end

  def cancel
    @resource.cancel!
    render partial: 'moderations/posters/poster', object: @resource
  end

private

  def scope klass:, moderation_state:
    scope = Animes::CensoredPostersQuery.call(
      klass:,
      moderation_state:
    )

    if moderation_state == @default_state
      scope
    else
      scope.except(:order).order(updated_at: :desc)
    end
  end

  def poster_by_id # rubocop:disable Metrics/AbcSize
    @collection = params.key?(:redirected) ?
      QueryObjectBase.new(Poster).where(id: params[:id]) :
      @collection.where(id: params[:id])

    return if @collection.any?

    poster = Poster.find_by(id: params[:id])
    if poster
      redirect_to current_url(
        page: 1,
        state: poster.moderation_state,
        kind: poster.target.class.base_class.name.downcase,
        redirected: 1
      )
    end
  end
end
