class CommentsController < ShikimoriController
  include CanCanGet404Concern
  include CommentHelper

  load_and_authorize_resource only: %i[edit]

  def show # rubocop:disable AbcSize
    @resource ||= Comment.find_by(id: params[:id]) || nil_object

    authorize_access! unless nil_object?

    @view = Comments::View.new @resource, params[:action] == 'reply'

    og noindex: true, nofollow: true
    return render :missing, status: (xhr_or_json? ? :ok : :not_found) if nil_object?

    og(
      image: @resource.user.avatar_url(160),
      page_title: i18n_t('comment_by', nickname: @resource.user.nickname),
      description: @resource.body.gsub(%r{\[[/\w_ =-]+\]}, '')
    )

    render :show # have to manually call render otherwise comment display via ajax is broken
  end
  alias tooltip show
  alias reply show

  def edit
  end

  # все комментарии сущности до определённого коммента
  def fetch
    comment = Comment.find params[:comment_id]
    topic = params[:topic_type].constantize.find params[:topic_id]

    raise CanCan::AccessDenied unless comment.commentable == topic

    from = params[:skip].to_i
    to = [params[:limit].to_i, 100].min

    query = topic
      .comments
      .includes(:user, :topic)
      .offset(from)
      .limit(to)

    @collection = query
      .decorate
      .reverse

    render :collection, formats: :json
  end

  def replies
    replieable = Comment.find params[:comment_id]

    from = params[:skip].to_i
    to = [params[:limit].to_i, 100].min

    @collection = Comment
      .where(id: Comments::Reply.new(replieable).reply_ids)
      .includes(:user, :commentable)
      .order(created_at: :desc)
      .offset(from)
      .limit(to)
      .decorate
      .reverse
      .select { |comment| can? :read, comment }

    render :collection, formats: :json
  end

  def chosen
    comments = Comment
      .where(id: params[:ids].split(',').map(&:to_i))
      .includes(:user, :commentable)
      .limit(100)
      .decorate
      .select { |comment| can? :read, comment }

    @collection = params[:order] ? comments.reverse : comments

    render :collection, formats: :json
  end

  def preview
    @comment = Comment.new(preview_params).decorate

    if params[:comment][:target_type] && params[:comment][:target_id]
      @comment = DescriptionComment.new(
        @comment,
        params[:comment][:target_type],
        params[:comment][:target_id],
        params[:comment][:lang]
      )
    end

    render partial: 'comment', object: @comment, formats: :html
  end

  def smileys
    render partial: 'comments/smileys', formats: :html
  end

private

  def faye
    FayeService.new current_user, faye_token
  end

  def preview_params
    params
      .require(:comment)
      .permit(:body, :is_offtopic, :commentable_id, :commentable_type, :user_id)
      .tap do |comment|
        comment[:user_id] ||= current_user&.id # can be no current_user with broken cookies
        comment[:body] = Moderations::Banhammer.instance.censor comment[:body], nil
      end
  end

  def authorize_access!
    authorize! :read, @resource
  rescue CanCan::AccessDenied
    @resource = nil_object
  end

  def nil_object
    NoComment.new params[:id]
  end

  def nil_object?
    @resource.is_a? NoComment
  end
end
