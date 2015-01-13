class FayeService
  pattr_initialize :actor, :faye

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
    publisher.publish trackable, :deleted

    if trackable.kind_of?(Message)
      trackable.delete_by @actor
    else
      trackable.destroy
    end
  end

private
  def publisher
    FayePublisher.new @actor, @faye
  end
end
