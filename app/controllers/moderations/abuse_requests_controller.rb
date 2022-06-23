class Moderations::AbuseRequestsController < ModerationsController
  load_and_authorize_resource only: %i[show]

  before_action :authenticate_user!, only: %i[index show accept reject]
  before_action :fetch_resource, only: %i[accept reject cleanup]
  before_action :check_access, only: %i[accept reject cleanup]

  PER_PAGE = 25

  def index
    og page_title: i18n_t('page_title.index')

    @processed = QueryObjectBase.new(processed_scope).paginate(@page, PER_PAGE)

    unless request.xhr?
      @moderators = moderators_scope
      @pending = pending_scope
    end
  end

  def show
    og noindex: true
    og page_title: i18n_t('page_title.show', id: @resource.id)
    breadcrumb i18n_t('page_title.index'), moderations_abuse_requests_url
  end

  def accept
    @resource.accept! approver: current_user, faye_token: faye_token
    render json: {}
  end

  def reject
    @resource.reject! approver: current_user
    render json: {}
  end

  def cleanup
    @resource.update! reason: nil
    render json: {}
  end

private

  def fetch_resource
    @resource = AbuseRequest.find params[:id]
  end

  def check_access
    raise CanCan::AccessDenied unless can? :manage, @resource
  end

  def processed_scope
    scope = AbuseRequest
      .not_bannable
      .where.not(state: :pending)

    unless can? :manage, AbuseRequest
      scope = scope
        .where(kind: %i[summary offtopic convert_review])
        .or(AbuseRequest.where(state: :accepted))
    end

    scope
      .includes(
        :user,
        :approver,
        topic: %i[linked user forum],
        comment: %i[commentable user]
      )
      .order(updated_at: :desc)
      # .joins(comment: :topic)
      # .where(kind: :abuse) # for test purposes
      # .where(topics: { linked_type: Club.name })
  end

  def pending_scope
    AbuseRequest
      .not_bannable
      .where(state: :pending)
      .includes(:user, :approver, comment: :commentable)
      .order(:created_at)
  end

  def moderators_scope
    User
      .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end
end
