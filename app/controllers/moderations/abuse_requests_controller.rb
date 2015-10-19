# TODO: переделать авторизацию на cancancan
class Moderations::AbuseRequestsController < ModerationsController
  include MessagesHelper # для работы хелпера format_linked_name

  before_filter :authenticate_user!, only: [:index, :show, :take, :deny, :offtopic, :review, :spoiler, :abuse]

  def index
    @processed = postload_paginate(params[:page], 25) do
      AbuseRequest
        .where(kind: ['review', 'offtopic'])
        .where.not(state: 'pending')
        .includes(:user, :approver, comment: :commentable)
        .order(updated_at: :desc)
    end

    unless request.xhr?
      page_title t('moderations.show.forum_journal')
      @pending = AbuseRequest
        .pending
        .includes(:user, :approver, comment: :commentable)
        .order(:created_at)

      @moderators = User.where(id: User::Moderators - User::Admins).sort_by { |v| v.nickname.downcase }
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

  def review
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).review(faye_token)
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
    raise Forbidden unless @request.can_process? current_user
    @request.take! current_user

    render json: {}
  end

  # отказ запроса
  def deny
    @request = AbuseRequest.find params[:id]
    raise Forbidden unless @request.can_process? current_user
    @request.reject! current_user

    render json: {}
  end
end
