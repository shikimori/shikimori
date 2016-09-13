class Comment::Create < ServiceObjectBase
  pattr_initialize :faye, :params, :locale

  instance_cache :commentable_object

  def call
    comment = Comment.new params

    RedisMutex.with_lock(mutex_key) do
      set_topic comment
      faye.create comment
    end

    comment
  end

private

  def mutex_key
    'comment_'\
      "#{params[:commentable_id]}_"\
      "#{params[:commentable_type]}"
  end

  def set_topic comment
    return unless comment.valid?
    return if commentable_klass <= Topic
    return if commentable_klass <= User

    comment.commentable = find_or_generate_topic
  end

  def find_or_generate_topic
    commentable_object.topic(locale) ||
      commentable_object.generate_topics(locale).first
  end

  # NOTE: Topic, User or DbEntry
  def commentable_klass
    params[:commentable_type].constantize
  end

  def commentable_object
    commentable_klass.find params[:commentable_id]
  end
end
