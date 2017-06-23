class ContestsController < ShikimoriController
  load_and_authorize_resource

  before_action { page_title i18n_t :contests }

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: -> { @resource }

  before_action :set_breadcrumbs

  LIMIT = 20

  def current
    if user_signed_in?
      redirect_to Contest.current.select { |v| current_user.can_vote?(v) }.first || Contest.current.last || root_url
    else
      redirect_to Contest.current.last || root_url
    end
  end

  def index
    keywords i18n_t('index_keywords')
    description i18n_t('index_description')

    @page = [params[:page].to_i, 1].max
    @collection = Contests::Query.fetch.paginate(@page, LIMIT)
  end

  def show
    noindex if params[:round] || params[:vote]
    return redirect_to edit_contest_url(@resource) if @resource.created?
    return redirect_to contest_url(@resource) if params[:round] && !@resource.displayed_round

    keywords i18n_t :show_keywords, title: @resource.title
    description i18n_t :show_description, title: Unicode::downcase(@resource.title)

    page_title @resource.displayed_round.title if params[:round]
  end

  # проголосовавшие в раунде
  def users
    unless @resource.displayed_match.finished? || (user_signed_in? && current_user.admin?)
      return redirect_to contest_url(@resource)
    end
    noindex

    page_title @resource.displayed_round.title
    page_title i18n_t :votes
  end

  # турнирная сетка
  def grid
    if !user_signed_in? || !current_user.contests_moderator?
      return redirect_to contests_url if @resource.created?
      return redirect_to contest_url(@resource) if @resource.proposing?
    end
    noindex

    page_title @resource.title
    page_title t 'tournament_bracket'

    @blank_layout = true
  end

  def edit
    page_title i18n_t :edit_contest
  end

  def new
    page_title i18n_t :new_contest

    @resource ||= Contest.new.decorate
    @resource.started_on ||= Time.zone.today + 1.day
    @resource.matches_per_round ||= 6
    @resource.match_duration ||= 2
    @resource.matches_interval ||= 1
    @resource.suggestions_per_user ||= 5
  end

  def create
    @resource.user_id = current_user.id

    if @resource.save
      redirect_to edit_contest_url(@resource), notice: i18n_t(:contest_created)
    else
      new
      render :new
    end
  end

  def update
    if (@resource.created? || @resource.proposing?) && params[:contest][:member_ids]
      @resource.links = []
      params[:contest][:member_ids]
        .map(&:to_i)
        .select { |member_id| member_id != 0 }
        .each do |member_id|
          @resource.object.members << @resource.member_klass.find(member_id)
        end
    end

    if @resource.update contest_params
      # сброс сгенерённых
      if @resource.can_start? && @resource.rounds.any?
        Contests::GenerateRounds.call @resource
      end

      redirect_to edit_contest_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t 'changes_not_saved'
      edit
      render :edit
    end
  end

  # запуск контеста
  def start
    Contest::Start.call @resource.object
    redirect_to edit_contest_url @resource
  end

  # запуск приёма варинатов
  def propose
    @resource.propose!
    redirect_to edit_contest_url @resource
  end

  # остановка приёма варинатов
  def stop_propose
    @resource.stop_propose!
    redirect_to edit_contest_url @resource
  end

  # очистка вариантов от накруток
  def cleanup_suggestions
    Contest::CleanupSuggestions.call @resource.object
    redirect_to edit_contest_url @resource
  end

  # остановка контеста
  #def finish
    #@resource.finish!
    #redirect_to edit_contest_url(@resource)
  #end

  # создание голосований
  def build
    if @resource.created? || @resource.proposing?
      Contests::GenerateRounds.call @resource.object
    end

    redirect_to edit_contest_url @resource
  end

private

  # хлебные крошки
  def set_breadcrumbs
    breadcrumb i18n_t('contests'), contests_url
    breadcrumb @resource.title, contest_url(@resource) if params[:action] == 'edit' && !@resource.created?
    breadcrumb @resource.title, contest_url(@resource) if params[:action] == 'grid' && !@resource.created?
    breadcrumb @resource.title, contest_url(@resource) if params[:round].present?

    if params[:action] == 'users'
      breadcrumb @resource.title, contest_url(@resource)
      breadcrumb @resource.displayed_round.title, round_contest_url(@resource, round: @resource.displayed_round)
    end
  end

  def contest_params
    params
      .require(:contest)
      .permit(
        :title_ru,
        :title_en,
        :started_on,
        :phases,
        :matches_per_round,
        :match_duration,
        :matches_interval,
        :user_vote_key,
        :wave_days,
        :strategy_type,
        :suggestions_per_user,
        :member_type
    )
  end
end
