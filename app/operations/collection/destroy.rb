class Collection::Destroy
  method_object :collection, :actor

  def call
    changelog
    @collection.destroy
  end

private

  def changelog
    NamedLogger.changelog.info(
      user_id: @actor.id,
      action: :destroy,
      collection: @collection.attributes
    )
  end
end
