class Comment::Create < ServiceObjectBase
  pattr_initialize :faye, :params

  def call
    comment = Comment.new params
    RedisMutex.with_lock(mutex_key) do
      set_topic comment
      faye.create comment
    end

    comment
  end

private

  attr_reader :params

  def mutex_key
    "comment_"\
      "#{params[:commentable_id]}_"\
      "#{params[:commentable_type]}"
  end

  def set_topic comment
    return unless comment.valid?
    return if commentable_klass <= Entry

    comment.commentable = find_or_generate_topic
  end

  def find_or_generate_topic
    unless commentable_object.topic
      commentable_object.generate_topic
    end

    commentable_object.topic
  end

  def commentable_klass
    params[:commentable_type].constantize
  end

  def commentable_object
    commentable_klass.find params[:commentable_id]
  end
end
