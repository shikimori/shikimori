class CommentsService
  def initialize actor, faye
    @actor = actor
    @faye = faye
  end

  def create params
    comment = Comment.new params
    comment.user_id = @actor.id

    publisher.publish comment, :created if comment.save
    comment
  end

  def update comment, params
    raise Forbidden unless comment.can_be_edited_by? @actor

    if comment.update params
      publisher.publish comment, :updated
      true
    else
      false
    end
  end

  def destroy comment
    raise Forbidden unless comment.can_be_deleted_by? @actor
    publisher.publish comment, :deleted
    comment.destroy
  end

private
  def publisher
    FayePublisher.new @actor, @faye
  end
end
