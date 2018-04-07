class CommentsController < ShikimoriController
  include CommentHelper

  COMMENT_PARAMS = %i[
    body is_summary is_offtopic commentable_id commentable_type user_id
  ]

  def show
    og noindex: true
    comment = Comment.find_by(id: params[:id]) || NoComment.new(params[:id])
    @view = Comments::View.new comment, false

    if comment.is_a? NoComment
      render :missing
    else
      render :show
    end
  end

  def tooltip
    show
  end

  def reply
    comment = Comment.find params[:id]
    @view = Comments::View.new comment, true
    render :show
  end

  def edit
    @comment = Comment.find params[:id]
  end

  # динамическая подгрузка комментариев при скролле
  # def postloader
    # @limit = [[params[:limit].to_i, 1].max, 100].min
    # @offset = params[:offset].to_i
    # @page = (@offset+@limit) / @limit

    # @comments, @add_postloader = CommentsQuery
      # .new(params[:commentable_type], params[:commentable_id], params[:is_summary].present?)
      # .postload(@page, @limit, true)
  # end

  def fetch
    comment = Comment.find(params[:comment_id])
    topic = params[:topic_type].constantize.find(params[:topic_id])

    raise Forbidden unless comment.commentable == topic
    from = params[:skip].to_i
    to = [params[:limit].to_i, 100].min

    query = topic
      .comments
      .includes(:user, :topic)
      .offset(from)
      .limit(to)

    query.where! is_summary: true if params[:is_summary]

    @collection = query
      .decorate
      .reverse

    render :collection, formats: :json
  end

  def chosen
    comments = Comment
      .where(id: params[:ids].split(',').map(&:to_i))
      .includes(:user, :commentable)
      .limit(100)
      .decorate

    @collection = params[:order] ? comments.reverse : comments

    render :collection, formats: :json
  end

  def preview # rubocop:disable AbcSize
    @comment = Comment.new(preview_params).decorate

    # это может быть предпросмотр не просто текста, а описания к аниме или манге
    if params[:comment][:target_type] && params[:comment][:target_id]
      @comment = DescriptionComment.new(
        @comment,
        params[:comment][:target_type],
        params[:comment][:target_id]
      )
    end

    render @comment
  end

  # смайлики для комментария
  def smileys
    render partial: 'comments/smileys'
  end

private

  def faye
    FayeService.new current_user, faye_token
  end

  def preview_params
    params
      .require(:comment)
      .permit(*COMMENT_PARAMS)
      .tap do |comment|
        comment[:user_id] ||= current_user.id
      end
  end
end
