# TODO: переделать авторизацию на cancancan
class Moderations::BansController < ModerationsController
  before_action :authenticate_user!, except: [:index]
  layout false, only: [:new]

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    @moderators = User
      .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }

    @bans = postload_paginate(params[:page], 25) do
      Ban.includes(:comment).order(created_at: :desc)
    end

    @site_rules = StickyTopicView.site_rules(locale_from_host)
    @club = Club.find_by(id: 917)&.decorate if ru_host?

    if user_signed_in? && current_user.forum_moderator?
      @declined = AbuseRequest
        .where(state: 'rejected', kind: %i[spoiler abuse])
        .order(id: :desc)
        .limit(15)
      @pending = AbuseRequest
        .where(state: 'pending')
        .includes(:user, :approver, comment: :commentable)
        .order(:created_at)
    end
  end

  def new
    @comment = Comment.find params[:comment_id]
    @abuse_request = AbuseRequest.find params[:abuse_request_id] if params[:abuse_request_id]
    @ban = Ban.new comment_id: @comment.id, user_id: @comment.user_id, abuse_request_id: params[:abuse_request_id]
    @ban.duration = @ban.suggest_duration
  end

  def create
    raise Forbidden unless current_user.forum_moderator?
    @resource = Ban.new ban_params

    if @resource.save
      render :create, formats: :json
    else
      render json: @resource.errors.full_messages, status: :unprocessable_entity
    end

  rescue StateMachine::InvalidTransition
  end

private

  def ban_params
    params
      .require(:ban)
      .permit(:reason, :duration, :comment_id, :abuse_request_id, :user_id)
      .merge(moderator_id: current_user.id)
  end
end
