class Api::V1::CommentsController < Api::V1::ApiController
  respond_to :json

  before_filter :authenticate_user!, only: [:create, :update, :destroy]
  before_filter :check_post_permission, only: [:create, :update, :destroy]
  before_filter :prepare_edition, only: [:edit, :create, :update, :destroy]

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/comments/:id', 'Show a comment'
  def show
    respond_with Comment.find(params[:id]).decorate
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/comments', 'List comments'
  def index
    @limit = [[params[:limit].to_i, 1].max, 30].min
    @page = [params[:page].to_i, 1].max
    @desc = params[:desc].nil? || params[:desc] == '1'

    raise MissingApiParameter, :commentable_type if params[:commentable_type].blank?
    raise MissingApiParameter, :commentable_id if params[:commentable_id].blank?

    respond_with CommentsQuery
      .new(params[:commentable_type], params[:commentable_id])
      .fetch(@page, @limit, @desc)
      .with_viewed(current_user)
      .decorate
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/comments', 'Create a comment'
  param :comment, Hash do
    param :body, :undef
    param :commentable_id, :number
    param :commentable_type, :undef
    param :is_offtopic, :bool
    param :is_summary, :bool
  end
  def create
    @comment = Comment.new create_params
    generate_missing_topic

    if faye.create @comment
      if params[:frontend]
        # incoming request form shiki editor has format json
        # render jbuilder template
        render :create
      else
        # respond with serialized comment (using serializer)
        render json: @comment.decorate
      end
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PATCH, '/comments/:id', 'Update a comment'
  api :PUT, '/comments/:id', 'Update a comment'
  param :comment, Hash do
    param :body, :undef
  end
  def update
    raise CanCan::AccessDenied unless @comment.can_be_edited_by? current_user

    if faye.update @comment, update_params
      if params[:frontend]
        # incoming request form shiki editor has format json
        # render jbuilder template
        render :create
      else
        # respond with serialized comment (using serializer)
        render json: @comment.decorate
      end
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/comments/:id', 'Destroy a comment'
  def destroy
    raise CanCan::AccessDenied unless @comment.can_be_deleted_by? current_user
    faye.destroy @comment

    render json: { notice: i18n_t('comment.removed') }
  end

private

  # TODO: remove 'offtopic' and 'review' after 01.09.2016
  def comment_params
    comment_params = params
      .require(:comment)
      .permit(
        :body, :review, :offtopic, :is_summary, :is_offtopic,
        :commentable_id, :commentable_type, :user_id
      )

    comment_params[:is_summary] ||= comment_params[:review]
    comment_params[:is_offtopic] ||= comment_params[:offtopic]

    comment_params.except(:review, :offtopic)
  end

  def create_params
    comment_params.merge(user: current_user)
  end

  def update_params
    comment_params.except(:is_summary, :is_offtopic)
  end

  def prepare_edition
    @comment = Comment.find(params[:id]).decorate if params[:id]
  end

  def generate_missing_topic
    return unless @comment.valid?
    return if commentable_klass <= Entry

    commentable_object.generate_topic
    @comment.commentable = commentable_object.topic
  end

  def commentable_klass
    comment_params[:commentable_type].constantize
  end

  def commentable_object
    commentable_klass.find comment_params[:commentable_id]
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
