class ContestsController < ShikimoriController
  before_action :fetch_resource, if: :resource_id

  authorize_resource except: %i[current index grid]
  before_action :authorize_read!, only: %i[grid]

  before_action :resource_redirect, if: -> { @resource }

  before_action { og page_title: i18n_t(:contests) }
  before_action :set_breadcrumbs
  before_action :js_export, only: %i[show]

  LIMIT = 40
  PARAMS = %i[
    title_ru
    title_en
    description_ru
    description_en
    started_on
    phases
    matches_per_round
    match_duration
    matches_interval
    user_vote_key
    wave_days
    strategy_type
    suggestions_per_user
    member_type
  ]

  def current
    contests = Contests::CurrentQuery.call

    if user_signed_in?
      not_voted = contests.find { |contest| current_user.can_vote? contest }
      return redirect_to(not_voted) if not_voted
    end

    redirect_to contests.last || root_url
  end

  def index
    og keywords: i18n_t('index_keywords')
    og description: i18n_t('index_description')

    @collection = Contests::Query.fetch.paginate(@page, LIMIT)
  end

  def show
    return redirect_to edit_contest_url(@resource) if @resource.created?
    if params[:round] && !@resource.displayed_round
      return redirect_to contest_url(@resource)
    end

    og noindex: true if params[:round] || params[:vote]
    og keywords: i18n_t(:show_keywords, title: @resource.title)
    og description: i18n_t(
      :show_description,
      title: Unicode.downcase(@resource.title)
    )

    og page_title: @resource.displayed_round.title if params[:round]
  end

  def grid
    if !user_signed_in? || !current_user.contest_moderator?
      return redirect_to contests_url if @resource.created?
      return redirect_to contest_url(@resource) if @resource.proposing?
    end

    og noindex: true
    og page_title: @resource.title
    og page_title: t('tournament_bracket')

    @blank_layout = true
  end

  def edit
    og page_title: i18n_t(:edit_contest)
  end

  def new
    og page_title: i18n_t(:new_contest)

    @resource ||= Contest.new
    @resource = @resource.decorate
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
    if (@resource.created? || @resource.proposing?) &&
        params[:contest][:member_ids]
      @resource.links = []
      params[:contest][:member_ids]
        .map(&:to_i)
        .reject(&:zero?)
        .each do |member_id|
          @resource.object.members << @resource.member_klass.find(member_id)
        end
    end

    if @resource.update contest_params
      # сброс сгенерённых
      if @resource.may_start? && @resource.rounds.any?
        Contests::GenerateRounds.call @resource.object
      end

      redirect_to edit_contest_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t 'changes_not_saved'
      edit
      render :edit
    end
  end

  def start
    Contest::Start.call @resource.object
    redirect_to edit_contest_url @resource
  end

  def propose
    @resource.propose!
    redirect_to edit_contest_url @resource
  end

  def stop_propose
    @resource.stop_propose!
    redirect_to edit_contest_url @resource
  end

  def cleanup_suggestions
    Contest::CleanupSuggestions.call @resource.object
    redirect_to edit_contest_url @resource
  end

  def build
    if @resource.created? || @resource.proposing?
      Contests::GenerateRounds.call @resource.object
    end

    redirect_to edit_contest_url @resource
  end

private

  def set_breadcrumbs
    breadcrumb i18n_t('contests'), contests_url

    if %w[edit grid].include?(params[:action]) && !@resource.created?
      breadcrumb @resource.title, contest_url(@resource)
    end

    if params[:round].present?
      breadcrumb @resource.title, contest_url(@resource)
    end
  end

  def authorize_read!
    authorize! :read, @resource
  end

  def contest_params
    params.require(:contest).permit(*PARAMS) if params[:contest]
  end

  def js_export
    gon.push votes: @resource.js_export
  end
end
