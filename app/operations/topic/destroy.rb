class Topic::Destroy
  method_object :model, :faye

  def call
    Changelog::LogDestroy.call @model, @faye.actor
    @faye.destroy @model
  end
end
