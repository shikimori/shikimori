class FayeService
  def initialize actor, faye
    @actor = actor
    @faye = faye
  end

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
    trackable.destroy
  end

private
  def publisher
    FayePublisher.new @actor, @faye
  end
end
