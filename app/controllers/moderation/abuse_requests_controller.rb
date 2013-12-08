class Moderation::AbuseRequestsController < ApplicationController
  include MessagesHelper # для работы хелпера format_linked_name
  include TopicsHelper # для работы MesasgesHelper - topic_url там хелпер
  include ActionView::Helpers::SanitizeHelper

  before_filter :authenticate_user!, only: [:index, :take, :deny, :offtopic, :review, :spoiler, :abuse]

  def index
    raise Forbidden unless current_user.abuse_requests_moderator?

    @processed = postload_paginate(params[:page], 25) do
      AbuseRequest
        .where(kind: ['review', 'offtopic'])
        .where { state.not_eq('pending') }
        .includes(:user, :approver, comment: :commentable)
        .order('updated_at desc')

    end.each do |req|
      formatted = format_linked_name(req.comment.commentable_id, req.comment.commentable_type, req.comment.id)

      req.comment[:topic_name] = '<span class="normal">'+formatted.match(/^(.*?)</)[1] + "</span> " + sanitize(formatted.match(/>(.*?)</)[1])
      req.comment[:topic_url] = formatted.match(/href="(.*?)"/)[1]
    end

    render json: {
      content: render_to_string(partial: 'abuse_request', collection: @processed, formats: :html) + (@add_postloader ?
        render_to_string(partial: 'site/postloader_new', locals: { url: page_abuse_requests_url(page: @page+1) }, formats: :html) :
        '')
    } and return if json?

    @page_title = 'Жалобы пользователей'
    @pending = AbuseRequest
        .pending
        .includes(:user, :approver, comment: :commentable)
        .order(:created_at)
        .order(:created_at)
        .all
        .each do |req|
      formatted = format_linked_name(req.comment.commentable_id, req.comment.commentable_type, req.comment.id)

      req.comment[:topic_name] = '<span class="normal">'+formatted.match(/^(.*?)</)[1] + "</span> " + sanitize(formatted.match(/>(.*?)</)[1])
      req.comment[:topic_url] = formatted.match(/href="(.*?)"/)[1]
    end

    @moderators = User.where(id: User::AbuseRequestsModerators - User::Admins).all.sort_by { |v| v.nickname.downcase }
  end

  def offtopic
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).offtopic
    render :create
  end

  def review
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).review
    render :create
  end

  def abuse
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).abuse
    render :create
  end

  def spoiler
    @comment = Comment.find params[:comment_id]
    @ids = AbuseRequestsService.new(@comment, current_user).spoiler
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
