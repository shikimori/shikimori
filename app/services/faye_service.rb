# сервис через который должны создаваться/изменяться/удаляться все объекты,
# отображаемые на форуме и имеющие realtime обновления
class FayeService
  pattr_initialize :actor, :publisher_faye_id

  def create trackable
    if trackable.save
      publisher.publish trackable, :created
      true
    else
      false
    end
  end

  def update trackable, params
    if trackable.update params
      publisher.publish trackable, :updated
      true
    else
      false
    end
  end

  def destroy trackable
    if trackable.kind_of?(Message)
      trackable.delete_by @actor
    else
      publisher.publish trackable, :deleted
      trackable.destroy
    end
  end

  def offtopic comment, value
    ids = comment.mark 'offtopic', value
    publisher.publish_marks ids, 'offtopic', comment.offtopic?
    ids
  end

  def review comment, value
    ids = comment.mark 'review', value
    publisher.publish_marks ids, 'review', comment.review?
    ids
  end

private
  def publisher
    FayePublisher.new @actor, @publisher_faye_id
  end
end
