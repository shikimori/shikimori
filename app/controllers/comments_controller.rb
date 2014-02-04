class CommentsController < ApplicationController
  include CommentHelper

  before_filter :check_auth, only: [:edit, :create, :update, :destroy]
  before_filter :check_post_permission, only: [:create, :update, :destroy]
  before_filter :prepare_edition, only: [:edit, :create, :update, :destroy]

  def show
    comment = Comment.includes(:user).find(params[:id])

    respond_to do |format|
      format.html {
        render partial: 'comments/comment', layout: false, object: comment, formats: :html
      }
      format.json {
        render json: {
          user: comment.user.nickname,
          body: comment.body,
          id: comment.id,
          offtopic: comment.offtopic?,
          kind: 'comment'
        }
      }
    end
  end

  def edit
    respond_to do |format|
      format.html do
        render partial: 'comments/add', layout: false, locals: {
          options: {
            text: @comment.body,
            review: @comment.review?,
            offtopic: @comment.offtopic?,
            object: @comment.commentable,
            editable: @comment
          }
        }
      end
    end
  end

  def create
    @comment = Comment.new comment_params
    @comment.user_id = current_user.id

    if @comment.save
      # отправка уведомлений о создании комментария
      FayePublisher.publish_comment(@comment, params[:faye]) if Rails.env != 'test'

      render json: {
        id: @comment.id,
        notice: 'Комментарий создан',
        html: render_to_string(partial: 'comments/comment', layout: false, object: @comment, locals: { topic: @comment.commentable }), formats: :html
      }
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    raise Forbidden unless @comment.can_be_edited_by?(current_user)
    params.except! :offtopic, :review

    if @comment.update_attributes comment_params
      render json: {
        id: @comment.id,
        notice: 'Комментарий изменен',
        html: render_to_string(partial: 'comments/comment', layout: false, object: @comment, locals: { topic: @comment.commentable }), formats: :html
      }
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    raise Forbidden unless @comment.can_be_deleted_by?(current_user)
    @comment.destroy

    commentable_klass = Object.const_get(@comment.commentable_type.to_sym)
    commentable = commentable_klass.find(@comment.commentable_id)
    result = commentable.comment_deleted(@comment) if commentable.respond_to?(:comment_deleted)

    if result && result.respond_to?(:[]) && result[:url_object]
      render json: {
        url: url_for(result[:url_object]),
        notice: result[:notice] ? result[:notice] : 'Комментарий удален'
      }
    else
      render json: {
        notice: 'Комментарий удален'
      }
    end
  end

  # динамическая подгрузка комментариев при скролле
  def postloader
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @offset = params[:offset].to_i
    @page = (@offset+@limit) / @limit

    @comments, @add_postloader = CommentsQuery
      .new(params[:commentable_type], params[:commentable_id])
      .postload(@page, @limit, true)
  end

  # все комментарии сущности до определённого коммента
  def fetch
    comment = Comment.find(params[:id])
    entry = Entry.find(params[:topic_id])

    raise Forbidden unless comment.commentable_id == entry.id && (
                             comment.commentable_type == entry.class.name || (
                               entry.respond_to?(:base_class) && comment.commentable_type == entry.base_class.name
                           ))
    from = params[:skip].to_i
    to = [params[:limit].to_i, 100].min

    comments = entry.comments.with_viewed(current_user)
        .includes(:user, :commentable)
        .offset(from)
        .limit(to)
        .reverse

    render partial: 'comments/comment', collection: comments, formats: :html
  end

  # список комментариев по запросу
  def chosen
    comments = Comment.with_viewed(current_user)
                      .where(id: params[:ids].split(',').map(&:to_i))
    comments.reverse! if params[:order]

    render partial: 'comments/comment', collection: comments, formats: :html
  end

  # предпросмотр текста
  def preview
    if params[:target_type] && params[:target_id]
      render text: BbCodeFormatter.instance.format_description(params[:body], params[:target_type].constantize.find(params[:target_id]))
    else
      render text: BbCodeFormatter.instance.format_comment(params[:body])
    end
  end

  # смайлики для комментария
  def smileys
    render partial: 'comments/smileys'
  end

private
  def prepare_edition
    raise Unauthorized unless user_signed_in?
    Rails.logger.info params.to_yaml

    @comment = Comment.find(params[:id]) if params[:id]
  end

  def comment_params
    params
      .require(:comment)
      .permit(:body, :review, :offtopic, :commentable_id, :commentable_type)
  end
end
