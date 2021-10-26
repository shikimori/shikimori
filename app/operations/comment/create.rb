class Comment::Create
  method_object :faye, :params, :locale

  def call
    comment = Comment.new @params.except(:commentable_id, :commentable_type)

    RedisMutex.with_lock(mutex_key, block: 30.seconds, expire: 30.seconds) do
      apply_commentable comment
    end
    @faye.create comment

    notify_user comment if profile_comment?
    touch_topic comment if topic_comment?

    comment
  end

private

  def mutex_key
    'comment_'\
      "#{@params[:commentable_id]}_"\
      "#{@params[:commentable_type]}"
  end

  def apply_commentable comment
    return if commentable_klass == NilClass

    if no_topic_generation? commentable_klass
      comment.assign_attributes @params.slice(:commentable_id, :commentable_type)
    else
      comment.commentable = find_or_generate_topic
    end
  end

  def find_or_generate_topic
    commentable_object.topic(@locale) ||
      commentable_object.generate_topics(@locale).first
  end

  def notify_user comment
    User::NotifyProfileCommented.call comment
  end

  def touch_topic comment
    comment.commentable.touch
  end

  # NOTE: Topic, User, Review or DbEntry
  def commentable_klass
    @params[:commentable_type].constantize
  rescue NameError
    NilClass
  end

  def commentable_object
    @commentable_object ||= commentable_klass.find @params[:commentable_id]
  end

  def no_topic_generation? commentable_klass
    topic_comment? || profile_comment? || commentable_klass == Review
  end

  def topic_comment?
    commentable_klass <= Topic
  end

  def profile_comment?
    commentable_klass <= User
  end
end
