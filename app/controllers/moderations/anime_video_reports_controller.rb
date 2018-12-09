class Moderations::AnimeVideoReportsController < ModerationsController
  skip_before_action :authenticate_user!
  before_action :authenticate_user!, except: [:create]
  load_and_authorize_resource except: :index

  LIMIT = 20

  def index
    og page_title: i18n_t('page_title')

    @processed = QueryObjectBase.new(processed_scope).paginate(@page, LIMIT)

    unless request.xhr?
      @moderators = moderators_scope
      @pending = pending_scope
    end
  end

  def show
    og noindex: true
    og page_title: i18n_t('content_change', anime_video_report_id: @resource.id)
  end

  def create
    @resource.state ||= :pending
    @resource.save!
    head 200
  end

  def accept
    @resource.accept! current_user if @resource.can_accept?
    render :show
  end

  def accept_edit
    @resource.accept! current_user if @resource.can_accept?

    redirect_to edit_video_online_url(
      @resource.anime_video.anime,
      @resource.anime_video,
      host: AnimeOnlineDomain.host(@resource.anime_video.anime)
    )
  end

  def accept_broken
    if @resource.can_accept?
      @resource.accept! current_user
      @resource.anime_video.broken
    end
    render :show
  end

  def close_edit
    @resource.accept_only! current_user if @resource.can_accept_only?

    redirect_to edit_video_online_url(
      @resource.anime_video.anime,
      @resource.anime_video,
      host: AnimeOnlineDomain.host(@resource.anime_video.anime)
    )
  end

  def reject
    @resource.reject! current_user if @resource.can_reject?
    render :show
  end

  def work
    @resource.work! if @resource.can_work?
    render :show
  end

  def cancel
    @resource.cancel! current_user if @resource.can_cancel?
    render :show
  end

  def destroy
    @resource.anime_video.destroy! if @resource.uploaded?
    @resource.destroy!
    head 200
  end

private

  def anime_video_report_params
    params
      .require(:anime_video_report)
      .permit(:kind, :anime_video_id, :user_id, :message)
      .merge(user_agent: request.user_agent)
  end

  def processed_scope
    scope = AnimeVideoReport
      .includes(:user, anime_video: :author)
      .processed

    if params[:created_on]
      scope = scope.where(
        'created_at between ? and ?',
        Time.zone.parse(params[:created_on]).beginning_of_day,
        Time.zone.parse(params[:created_on]).end_of_day
      )
    end

    scope
  end

  def moderators_scope
    User
      .where("roles && '{#{Types::User::Roles[:video_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def pending_scope
    AnimeVideoReport
      .includes(:user, anime_video: :author)
      .pending
      .order(id: :desc)
      .limit(20)
  end
end
