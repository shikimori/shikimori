class Api::V1::CommentsController < Api::V1Controller # rubocop:disable ClassLength
  include CanCanGet404Concern
  before_action :check_post_permission, only: %i[create update destroy]
  load_and_authorize_resource only: %i[show create update destroy]

  LIMIT = 30

  before_action only: %i[create update destroy] do
    doorkeeper_authorize! :comments if doorkeeper_token.present?
  end

  api :GET, '/comments', 'List comments'
  param :commentable_id, :number, required: true
  param :commentable_type, Types::Comment::CommentableType.values,
    required: true,
    desc: <<~DOC.strip
      Must be one of: `#{Types::Comment::CommentableType.values.join('`, `')}`
    DOC
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  param :desc, %w[1 0], required: false
  def index # rubocop:disable AbcSize
    @limit = [[params[:limit].to_i, 1].max, LIMIT].min
    @desc = params[:desc].nil? || params[:desc] == '1'

    commentable_type = params[:commentable_type]
    commentable_id = params[:commentable_id]
    commentable = Types::Comment::CommentableType[commentable_type]
      .constantize
      .find(commentable_id)

    authorize! :read, commentable

    @collection = Comments::ApiQuery
      .new(commentable_type, commentable_id)
      .fetch(@page, @limit, @desc)
      .decorate

    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/comments/:id', 'Show a comment'
  def show
    respond_with @resource.decorate
  end

  COMMENTABLE_TYPES = [
    Anime,
    Manga,
    Character,
    Person,
    Article,
    Club,
    ClubPage,
    Collection,
    Critique,
    Review
  ].map(&:name)
  api :POST, '/comments', 'Create a comment'
  description 'Requires `comments` oauth scope'
  param :comment, Hash do
    param :body, String, required: true
    param :commentable_id, :number, required: true
    param :commentable_type, Types::Comment::CommentableType.values + COMMENTABLE_TYPES,
      required: true,
      desc: <<~DOC.squish
        <p>
          Must be one of:
          <code>#{Types::Comment::CommentableType.values.join('</code>, <code>')}</code>,
          #{COMMENTABLE_TYPES.map { |name| "<code>#{name}</code>" }.join(', ')}
        </p>
        <p>
          When set to
          #{COMMENTABLE_TYPES.map { |name| "<code>#{name}</code>" }.join(', ')}
          comment is attached to <code>commentable</code> main topic
        </p>
      DOC
    param :is_offtopic, :bool, required: false
  end
  param :frontend, :bool, 'Used by shikimori frontend code. Ignore it.'
  param :broadcast,
    :bool,
    "Used to broadcast comment in club's topic. Only club admins can broadcast."
  def create
    @resource = Comment::Create.call(
      params: create_params,
      faye: faye
    )

    if params[:broadcast] && @resource.persisted? && can?(:broadcast, @resource)
      Comment::Broadcast.call @resource
    end

    if @resource.persisted? && frontent_request?
      render :comment
    else
      respond_with @resource
    end
  end

  api :PATCH, '/comments/:id', 'Update a comment'
  api :PUT, '/comments/:id', 'Update a comment'
  description [
    'Requires `comments` oauth scope.',
    'Use `/api/v2/abuse_requests` to change `is_offtopic` field.'
  ].join(' ')
  param :comment, Hash do
    param :body, String, required: true
  end
  param :frontend, :bool
  def update
    is_updated = Comment::Update.call @resource, comment_params, faye

    if is_updated && frontent_request?
      render :comment
    else
      respond_with @resource
    end
  end

  api :DELETE, '/comments/:id', 'Destroy a comment'
  description 'Requires `comments` oauth scope'
  def destroy
    Comment::Destroy.call @resource, faye

    render json: { notice: i18n_t('comment.removed') }
  end

private

  def comment_params
    params
      .require(:comment)
      .permit(
        :body, :offtopic, :is_offtopic,
        :commentable_id, :commentable_type, :user_id
      )
      .except(:offtopic)
  end

  def create_params
    comment_params.merge(user: current_user)
  end

  def update_params
    params.require(:comment).permit(:body)
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
