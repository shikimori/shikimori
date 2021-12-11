class Collection::Destroy
  method_object :model, :actor

  def call
    Changelog::LogDestroy.call @model, @actor
    @model.destroy
  end
end
