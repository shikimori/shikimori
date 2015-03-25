class ContestsController < ShikimoriController
  load_and_authorize_resource

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: -> { @resource }

  before_action :set_breadcrumbs

  page_title 'Опросы'
  breadcrumb 'Опросы', :contests_url

  def current
    if user_signed_in?
      redirect_to Contest.current.select {|v| current_user.can_vote?(v) }.first || Contest.current.last || root_url
    else
      redirect_to Contest.current.last || root_url
    end
  end

  def index
    keywords 'аниме опросы турниры голосования'
    description 'Аниме опросы и турниры сайта'

    @collection_groups = @collection
      .includes(rounds: :matches)
      .sort_by {|v| [['started', 'proposing', 'created', 'finished'].index(v.state), -(v.finished_on || Date.today).to_time.to_i] }
      .group_by(&:state)
  end

  def show
    noindex if params[:round] || params[:vote]
    redirect_to edit_contest_url(@resource) and return if @resource.created?

    keywords 'аниме опрос турнир голосование ' + @resource.title
    description 'Примите участие в аниме-турнире на нашем сайте и внесите свой вклад в голосование, мы хотим определить ' + Unicode::downcase(@resource.title) + '.'

    page_title @resource.displayed_round.title if params[:round]
  end

  # проголосовавшие в раунде
  def users
    redirect_to contest_url(@resource) unless @resource.displayed_match.finished? || (user_signed_in? && current_user.admin?)
    noindex

    page_title @resource.displayed_round.title
    page_title 'Голоса'
  end

  # TODO: удалить после 05.2015
  def comments
    redirect_to UrlGenerator.instance.topic_url(@resource.thread), status: 301
  end

  # турнирная сетка
  def grid
    if !user_signed_in? || !current_user.contests_moderator?
      return redirect_to contests_url if @resource.created?
      return redirect_to contest_url(@resource) if @resource.proposing?
    end
    noindex

    page_title @resource.title
    page_title 'Турнирная сетка'

    @blank_layout = true
  end

  def edit
    page_title 'Изменение опроса'
  end

  def new
    page_title 'Новый опрос'

    @resource ||= Contest.new.decorate
    @resource.started_on ||= Date.today + 1.day
    @resource.matches_per_round ||= 6
    @resource.match_duration ||= 2
    @resource.matches_interval ||= 1
    @resource.suggestions_per_user ||= 5
  end

  def create
    @resource.user_id = current_user.id

    if @resource.save
      redirect_to edit_contest_url(@resource), notice: 'Опрос создан'
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
        .select {|v| v != 0 }
        .each do |v|
          @resource.members << @resource.member_klass.find(v)
        end
    end

    if @resource.update contest_params
      # сброс сгенерённых
      @resource.prepare if @resource.can_start? && @resource.rounds.any?

      redirect_to edit_contest_url(@resource), notice: 'Изменения сохранены'
    else
      flash[:alert] = 'Изменения не сохранены!'
      edit
      render :edit
    end
  end

  # запуск контеста
  def start
    @resource.start!
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
    @resource.cleanup_suggestions!
    redirect_to edit_contest_url @resource
  end

  # остановка контеста
  #def finish
    #@resource.finish!
    #redirect_to edit_contest_url(@resource)
  #end

  # создание голосований
  def build
    @resource.prepare if @resource.created? || @resource.proposing?
    redirect_to edit_contest_url @resource
  end

private
  # хлебные крошки
  def set_breadcrumbs
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
      .permit(:title, :description, :started_on, :phases, :matches_per_round, :match_duration,
        :matches_interval, :user_vote_key, :wave_days, :strategy_type, :suggestions_per_user, :member_type)
  end
end
