class Moderations::BansController < ModerationsController
  load_and_authorize_resource except: %i[index]
  before_action :authenticate_user!, except: %i[index]
  layout false, only: %i[new]

  PER_PAGE = 25

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title.index')

    @moderators = moderators_scope

    scope = Ban.includes(:comment).order(created_at: :desc)
    @collection = QueryObjectBase.new(scope).paginate(@page, PER_PAGE)

    @site_rules = StickyTopicView.site_rules(locale_from_host)
    @club = Club.find_by(id: 917)&.decorate if ru_host?

    if can? :manage, AbuseRequest
      @declined = declined_scope
      @pending = pending_scope
    end
  end

  def show
    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
    breadcrumb i18n_t('page_title.index'), moderations_bans_url
  end

  def new
  end

  def create
    if @resource.save
      Comment::WrapInSpoiler.call @resource.comment if ban_params[:hide_to_spoiler] == '1'
      render :create, formats: :json
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end
  # rescue AASM::InvalidTransition
  end

  def destroy
    @resource.destroy
    redirect_back fallback_location: moderation_profile_url(@resource.user)
  end

private

  def ban_params
    params
      .require(:ban)
      .permit(
        :reason,
        :duration,
        :hide_to_spoiler,
        :comment_id,
        :topic_id,
        :abuse_request_id,
        :user_id
      )
      .merge(moderator_id: current_user&.id)
  end

  def moderators_scope
    User
      .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def declined_scope
    AbuseRequest
      .bannable
      .where(state: :rejected)
      .order(id: :desc)
      .limit(15)
  end

  def pending_scope
    AbuseRequest
      .bannable
      .where(state: :pending)
      .includes(:user, :approver, comment: :commentable)
      .order(:created_at)
  end
end
