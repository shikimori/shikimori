class Comment::Create < ServiceObjectBase
  pattr_initialize :faye, :params, :locale

  instance_cache :commentable_object

  def call
    comment = Comment.new @params.except(:commentable_id, :commentable_type)

    RedisMutex.with_lock(mutex_key, block: 30.seconds, expire: 30.seconds) do
      apply_commentable comment
    end
    @faye.create comment
    if 

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

    if possibly_generate_topic? commentable_klass
      comment.commentable = find_or_generate_topic
    else
      comment.assign_attributes @params.slice(:commentable_id, :commentable_type)
    end
  end

  def find_or_generate_topic
    commentable_object.topic(@locale) ||
      commentable_object.generate_topics(@locale).first
  end

  # NOTE: Topic, User, Review or DbEntry
  def commentable_klass
    @params[:commentable_type].constantize
  rescue NameError
    NilClass
  end

  def commentable_object
    commentable_klass.find @params[:commentable_id]
  end

  def possibly_generate_topic? commentable_klass
    !(
      commentable_klass <= Topic ||
        commentable_klass <= User ||
        commentable_klass == Review
    )
  end
end
