class Changelog::LogDestroy < Changelog::LogUpdate
  method_object :model, :actor

  def call
    logger.info(
      user_id: @actor.id,
      action: :destroy,
      id: @model.id,
      model: @model
    )
  end

private

  def logger
    @logger ||= NamedLogger.send(
      :"changelog_#{model.class.base_class.name.downcase.pluralize}"
    )
  end
end
