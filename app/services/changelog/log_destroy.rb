class Changelog::LogDestroy < Changelog::LogUpdate
  method_object :model, :actor

  def call
    logger.info(
      user_id: @actor.id,
      action: :destroy,
      id: @model.id,
      model: @model.to_json
    )
  end

private

  def logger
    @logger ||= NamedLogger.send(
      :"changelog_#{model.class.base_class.name.underscore.pluralize}"
    )
  end
end
