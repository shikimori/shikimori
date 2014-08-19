class CommentsController < ShikimoriController
  include CommentHelper

  before_filter :authenticate_user!, only: [:edit, :create, :update, :destroy]
  before_filter :check_post_permission, only: [:create, :update, :destroy]
  before_filter :prepare_edition, only: [:edit, :create, :update, :destroy]

  def show
    @comment = Comment.find params[:id]
    respond_to do |format|
      format.html { render :show }
      format.json { render :show }
    end
  end

  def edit
    @comment = Comment.find params[:id]
  end

  def create
    #render json: ['Комментирование топика отключено'], status: :unprocessable_entity and return if comment_params[:commentable_id].to_i == 82468 && !current_user.admin?
    @comment = comments_service.create comment_params

    unless @comment.persisted?
      render json: @comment.errors, status: :unprocessable_entity, notice: 'Комментарий создан'
    end
  end

  def update
    if comments_service.update @comment, comment_params.except(:offtopic, :review)
      render :create
    else
      render json: @comment.errors, status: :unprocessable_entity, notice: 'Комментарий изменен'
    end
  end

  def destroy
    comments_service.destroy @comment

    render json: { notice: 'Комментарий удален' }
  end

  # динамическая подгрузка комментариев при скролле
  def postloader
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @offset = params[:offset].to_i
    @page = (@offset+@limit) / @limit

    @comments, @add_postloader = CommentsQuery
      .new(params[:commentable_type], params[:commentable_id], params[:review].present?)
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

    comments = entry
      .comments
      .with_viewed(current_user)
      .includes(:user, :commentable)
      .offset(from)
      .limit(to)
      .to_a
      .reverse

    render partial: 'comments/comment', collection: comments, formats: :html
  end

  # список комментариев по запросу
  def chosen
    comments = Comment
      .with_viewed(current_user)
      .where(id: params[:ids].split(',').map(&:to_i))
      .includes(:user, :commentable)
      .limit(100)
      .to_a

    comments.reverse! if params[:order]

    render partial: 'comments/comment', collection: comments, formats: :html
  end

  # предпросмотр текста
  def preview
    #if params[:target_type] && params[:target_id]
      #render text: BbCodeFormatter.instance.format_description(params[:body], params[:target_type].constantize.find(params[:target_id]))
    #else
      #render text: BbCodeFormatter.instance.format_comment(params[:body])
    #end
    @comment = Comment.new comment_params
    render partial: 'comments/comment', object: @comment
  end

  # смайлики для комментария
  def smileys
    render partial: 'comments/smileys'
  end

private
  def prepare_edition
    Rails.logger.info params.to_yaml
    @comment = Comment.find(params[:id]) if params[:id]
  end

  def comments_service
    CommentsService.new current_user, faye_token
  end

  def comment_params
    params
      .require(:comment)
      .permit(:body, :review, :offtopic, :commentable_id, :commentable_type, :user_id)
  end
end
