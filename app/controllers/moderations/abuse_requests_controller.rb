# TODO: переделать авторизацию на cancancan
class Moderations::AbuseRequestsController < ModerationsController
  before_action :authenticate_user!, only: [:index, :show, :take, :deny, :offtopic, :summary, :spoiler, :abuse]

  def index
    @processed = postload_paginate(params[:page], 25) do
      scope = AbuseRequest.where.not(state: :pending)

      unless current_user.forum_moderator?
        scope = scope
          .where(kind: %i(summary offtopic))
          .or(AbuseRequest.where(state: :accepted))
      end

      scope
        .includes(:user, :approver, comment: :commentable)
        .order(updated_at: :desc)
        .joins(comment: :topic)
        # .where(kind: :abuse) # for test purposes
        # .where(topics: { linked_type: Club.name })
    end

    unless request.xhr?
      og page_title: i18n_t('page_title')
      @pending = AbuseRequest
        .pending
        .includes(:user, :approver, comment: :commentable)
        .order(:created_at)

      @moderators = User
        .where("roles && '{#{Types::User::Roles[:forum_moderator]}}'")
        .where.not(id: User::MORR_ID)
        .sort_by { |v| v.nickname.downcase }
    end
  end

  def show
    @resource = AbuseRequest.find params[:id]
  end

  def offtopic
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).offtopic(faye_token)
    render :create
  end

  def summary
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).summary(faye_token)
    render :create
  end

  def abuse
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).abuse params[:reason]
    render :create
  end

  def spoiler
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).spoiler params[:reason]
    render :create
  end

  # принятие запроса
  def take
    @request = AbuseRequest.find params[:id]
    raise Forbidden unless current_user.forum_moderator?
    @request.take! current_user rescue StateMachine::InvalidTransition
    render json: {}
  end

  # отказ запроса
  def deny
    @request = AbuseRequest.find params[:id]
    raise Forbidden unless current_user.forum_moderator?
    @request.reject! current_user rescue StateMachine::InvalidTransition
    render json: {}
  end
end
