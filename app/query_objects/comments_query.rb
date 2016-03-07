class CommentsQuery
  LIMIT = 100

  def initialize commentable_type, commentable_id, review = false
    commentable_klass = commentable_type.camelize.constantize

    @commentable_type =
      if commentable_klass.respond_to?(:base_class)
        commentable_klass.base_class.name
      else
        commentable_klass.name
      end
    @commentable_id = commentable_id
    @review = review
  end

  def postload page, limit, descending
    comments = fetch(page, limit, descending).decorate.to_a
    [comments.take(limit), comments.size == limit+1]
  end

  def fetch page, limit, descending
    query = Comment
      .where(commentable_type: @commentable_type, commentable_id: @commentable_id)
      .includes(:user)
      .order("id #{descending ? :desc : :asc}")
      .offset(limit * (page-1))
      .limit(limit + 1)

    query.where! review: true if @review
    query
  end
end
