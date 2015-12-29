class CommentsController < ShikimoriController
  include CommentHelper

  before_filter :authenticate_user!, only: [:edit, :create, :update, :destroy]
  before_filter :check_post_permission, only: [:create, :update, :destroy]
  before_filter :prepare_edition, only: [:edit, :create, :update, :destroy]

  def show
    noindex
    comment = Comment.find(params[:id])#.decorate
    @view = Comments::View.new comment, false

    respond_to do |format|
      format.html { render :show }
      format.json { render :show }
    end
  end

  def reply
    comment = Comment.find params[:id]
    @view = Comments::View.new comment, true
    render :show
  end

  def edit
    @comment = Comment.find params[:id]
  end

  def create
    # if comment_params[:commentable_id].to_i == 152575 && !current_user.admin?
      # return render json: ['Комментирование топика отключено'], status: :unprocessable_entity
    # end

    @comment = Comment.new comment_params.merge(user: current_user)

    unless faye.create @comment
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    raise CanCan::AccessDenied unless @comment.can_be_edited_by? current_user

    if faye.update @comment, comment_params.except(:offtopic, :review)
      render :create
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    raise CanCan::AccessDenied unless @comment.can_be_deleted_by? current_user
    faye.destroy @comment

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
    comment = Comment.find(params[:comment_id])
    entry = params[:topic_type].constantize.find(params[:topic_id])

    raise Forbidden unless comment.commentable_id == entry.id && (
                             comment.commentable_type == entry.class.name || (
                               entry.respond_to?(:base_class) && comment.commentable_type == entry.base_class.name
                           ))
    from = params[:skip].to_i
    to = [params[:limit].to_i, 100].min

    query = entry
      .comments
      .with_viewed(current_user)
      .includes(:user, :commentable)
      .offset(from)
      .limit(to)

    query.where! review: true if params[:review]

    comments = query
      .decorate
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
      .decorate

    comments.reverse! if params[:order]

    render comments
  end

  # предпросмотр текста
  def preview
    @comment = Comment.new(comment_params).decorate

    # это может быть предпросмотр не просто текста, а описания к аниме или манге
    if params[:comment][:target_type] && params[:comment][:target_id]
      @comment = DescriptionComment.new(@comment,
        params[:comment][:target_type], params[:comment][:target_id])
    end

    render @comment
  end

  # смайлики для комментария
  def smileys
    render partial: 'comments/smileys'
  end

private

  def prepare_edition
    Rails.logger.info params.to_yaml
    @comment = Comment.find(params[:id]).decorate if params[:id]
  end

  def faye
    FayeService.new current_user, faye_token
  end

  def comment_params
    params
      .require(:comment)
      .permit(:body, :review, :offtopic, :commentable_id, :commentable_type, :user_id)
  end
end
