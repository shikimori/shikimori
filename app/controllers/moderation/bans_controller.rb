class Moderation::BansController < ApplicationController
  include MessagesHelper # для работы хелпера format_linked_name
  include TopicsHelper # для работы MesasgesHelper - topic_url там хелпер
  include ActionView::Helpers::SanitizeHelper

  before_filter :authenticate_user!, except: [:index]
  layout false, only: [:new]

  def index
    @page_title = 'Журнал модерации'

    @moderators = User.where(id: User::Moderators - User::Admins).all.sort_by { |v| v.nickname.downcase }
    @bans = postload_paginate(params[:page], 25) { Ban.includes(:comment).order 'created_at desc' }

    if user_signed_in? && current_user.moderator?
      @declined = AbuseRequest.where(state: 'rejected', kind: ['spoiler', 'abuse']).order('id desc').limit(15)
      @pending = AbuseRequest
          .where(state: 'pending')
          .includes(:user, :approver, comment: :commentable)
          .order(:created_at)
          .order(:created_at)
          .all
          .each do |req|
        formatted = format_linked_name(req.comment.commentable_id, req.comment.commentable_type, req.comment.id)

        req.comment[:topic_name] = '<span class="normal">'+formatted.match(/^(.*?)</)[1] + "</span> " + sanitize(formatted.match(/>(.*?)</)[1])
        req.comment[:topic_url] = formatted.match(/href="(.*?)"/)[1]
      end
    end
  end

  def new
    @comment = Comment.find params[:comment_id]
    @abuse_request = AbuseRequest.find params[:abuse_request_id] if params[:abuse_request_id]
    @ban = Ban.new comment_id: @comment.id, user_id: @comment.user_id, abuse_request_id: params[:abuse_request_id]
    @ban.duration = @ban.suggest_duration
  end

  def create
    raise Forbidden unless current_user.moderator?

    @ban = Ban.new ban_params
    render json: @ban.errors.full_messages, status: :unprocessable_entity unless @ban.save
  end

private
  def ban_params
    params
      .require(:ban)
      .permit(:reason, :duration, :comment_id, :abuse_request_id, :user_id)
      .merge(moderator_id: current_user.id)
  end
end
